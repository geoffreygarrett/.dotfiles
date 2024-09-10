use std::fs;
use std::fs::File;
use std::io::{Read, Write};
use std::path::{Path, PathBuf};
use std::process::Stdio;

use chrono::{DateTime, Local};
use colored::Colorize;
use log::{debug, error, info, trace, warn};

use crate::utils::{
    ask_for_confirmation, find_sops_file, get_custom_locations, is_git_repo, CheckedCommand,
};

pub struct SshKeyManager {
    ssh_dir: PathBuf,
    sops_file: PathBuf,
}

impl SshKeyManager {
    pub(crate) fn new(ssh_dir: Option<PathBuf>) -> Result<Self, String> {
        debug!("Initializing SshKeyManager");
        let ssh_dir = ssh_dir.unwrap_or_else(|| {
            let dir = dirs::home_dir()
                .expect("Could not find home directory")
                .join(".ssh");
            debug!("Using default SSH directory: {:?}", dir);
            dir
        });
        let sops_file = find_sops_file()?;
        debug!("Using SOPS file: {:?}", sops_file);
        Ok(Self { ssh_dir, sops_file })
    }

    pub(crate) fn sync(&self) -> Result<(), String> {
        info!("Starting SSH key sync");
        debug!("Using SSH directory: {:?}", self.ssh_dir);
        debug!("Using SOPS file: {:?}", self.sops_file);

        let sops_keys = self.read_sops_keys()?;
        let local_keys = self.read_local_keys()?;

        debug!("SOPS keys count: {}", sops_keys.len());
        debug!("Local keys count: {}", local_keys.len());

        if sops_keys.is_empty() && !local_keys.is_empty() {
            info!("SOPS file is empty. Updating SOPS with local keys.");
            return self.write_sops_keys(&local_keys);
        }

        if sops_keys == local_keys {
            info!("No changes detected. Keys are in sync.");
            return Ok(());
        }

        info!("Differences detected between local keys and SOPS secrets.");

        let local_modified = self.get_local_keys_last_modified()?;
        let sops_modified = self.get_last_modified(&self.sops_file)?;
        info!("Local keys last modified: {}", local_modified);
        info!("SOPS secrets last modified: {}", sops_modified);

        if ask_for_confirmation("Do you want to overwrite local keys with SOPS secrets?") {
            self.update_local_keys(&sops_keys)?;
            info!("Local keys updated successfully.");
        } else {
            info!("Sync cancelled. No changes made.");
        }

        Ok(())
    }

    pub(crate) fn generate(&self, name: &str, description: Option<&str>) -> Result<(), String> {
        info!("Generating new SSH key: {}", name);

        let key_path = self.ssh_dir.join(name);
        let pub_key_path = key_path.with_extension("pub");

        if key_path.exists() || pub_key_path.exists() {
            warn!("SSH key '{}' already exists", name);
            if !ask_for_confirmation(&format!("SSH key '{}' already exists. Overwrite?", name)) {
                info!("Key generation cancelled by user");
                return Ok(());
            }
        }

        let username = whoami::username();
        let hostname = whoami::fallible::hostname().unwrap_or_else(|e| {
            warn!("Failed to get hostname: {}", e);
            "unknown_host".to_string()
        });

        let identifier = format!("{}@{}", username, hostname);
        debug!("Using identifier: {}", identifier);

        info!("Executing ssh-keygen command");
        let output = CheckedCommand::new("ssh-keygen")
            .map_err(|e| format!("Failed to create ssh-keygen command: {}", e))?
            .arg("-t")
            .arg("ed25519")
            .arg("-f")
            .arg(&key_path)
            .arg("-N")
            .arg("")
            .arg("-C")
            .arg(&identifier)
            .output()
            .map_err(|e| format!("Failed to execute ssh-keygen: {}", e))?;

        if !output.status.success() {
            let error_msg = String::from_utf8_lossy(&output.stderr);
            error!("ssh-keygen failed: {}", error_msg);
            return Err(format!("ssh-keygen failed: {}", error_msg));
        }

        info!("SSH key pair generated successfully");
        println!("{}", "SSH key pair generated successfully.".green());
        println!("Private key: {}", key_path.display());
        println!("Public key: {}", pub_key_path.display());
        println!("Identifier: {}", identifier);

        debug!("Adding key to SOPS");
        self.add_to_sops(name, Some(&identifier))?;

        Ok(())
    }

    pub(crate) fn delete(&self, name: &str) -> Result<(), String> {
        info!("Deleting SSH key: {}", name);

        let key_path = self.ssh_dir.join(name);
        let pub_key_path = key_path.with_extension("pub");

        if !key_path.exists() && !pub_key_path.exists() {
            error!("No key found with name '{}'", name);
            return Err(format!("No key found with name '{}'", name));
        }

        let trash_dir = self.ssh_dir.join("trash");
        fs::create_dir_all(&trash_dir)
            .map_err(|e| format!("Failed to create trash directory: {}", e))?;

        if key_path.exists() {
            let trash_path = trash_dir.join(name);
            debug!("Moving private key to trash: {:?}", trash_path);
            fs::rename(&key_path, &trash_path)
                .map_err(|e| format!("Failed to move private key to trash: {}", e))?;
        }
        if pub_key_path.exists() {
            let trash_path = trash_dir.join(format!("{}.pub", name));
            debug!("Moving public key to trash: {:?}", trash_path);
            fs::rename(&pub_key_path, &trash_path)
                .map_err(|e| format!("Failed to move public key to trash: {}", e))?;
        }

        self.remove_from_sops(name)?;

        info!("SSH key '{}' deleted successfully", name);
        println!(
            "{}",
            format!("SSH key '{}' deleted successfully.", name).green()
        );
        Ok(())
    }

    fn read_sops_keys(&self) -> Result<Vec<String>, String> {
        debug!("Reading keys from SOPS file: {:?}", self.sops_file);
        let output = CheckedCommand::new("sops")
            .map_err(|e| format!("Failed to create SOPS command: {}", e))?
            .arg("-d")
            .arg(&self.sops_file)
            .output()
            .map_err(|e| format!("Failed to decrypt SOPS file: {}", e))?;

        if !output.status.success() {
            let err_msg = String::from_utf8_lossy(&output.stderr);
            error!("SOPS decryption failed: {}", err_msg);
            return Err(format!("SOPS decryption failed: {}", err_msg));
        }

        let decrypted = String::from_utf8_lossy(&output.stdout);
        let yaml: serde_yaml::Value =
            serde_yaml::from_str(&decrypted).map_err(|e| format!("Failed to parse YAML: {}", e))?;

        match yaml["ssh_keys"].as_mapping() {
            Some(ssh_keys) => {
                let keys: Vec<String> = ssh_keys
                    .values()
                    .filter_map(|v| v.as_str())
                    .map(String::from)
                    .collect();
                debug!("Read {} keys from SOPS file", keys.len());
                Ok(keys)
            }
            None => {
                warn!("No ssh_keys section found in SOPS file. Initializing with empty section.");
                self.initialize_sops_file()?;
                Ok(Vec::new())
            }
        }
    }

    fn initialize_sops_file(&self) -> Result<(), String> {
        info!("Initializing SOPS file with empty ssh_keys section");
        let initial_content = serde_yaml::to_string(&serde_yaml::Value::Mapping(
            serde_yaml::Mapping::from_iter(vec![(
                serde_yaml::Value::String("ssh_keys".to_string()),
                serde_yaml::Value::Mapping(serde_yaml::Mapping::new()),
            )]),
        ))
        .map_err(|e| format!("Failed to generate initial YAML: {}", e))?;

        if let Some(parent) = self.sops_file.parent() {
            fs::create_dir_all(parent)
                .map_err(|e| format!("Failed to create parent directories: {}", e))?;
        }

        fs::write(&self.sops_file, &initial_content)
            .map_err(|e| format!("Failed to write initial content to SOPS file: {}", e))?;

        let output = CheckedCommand::new("sops")
            .map_err(|e| format!("Failed to create SOPS command: {}", e))?
            .arg("-e")
            .arg("-i")
            .arg(&self.sops_file)
            .output()
            .map_err(|e| format!("Failed to run SOPS: {}", e))?;

        if !output.status.success() {
            return Err(format!(
                "SOPS encryption failed: {}",
                String::from_utf8_lossy(&output.stderr)
            ));
        }

        info!("SOPS file initialized successfully");
        Ok(())
    }

    fn read_local_keys(&self) -> Result<Vec<String>, String> {
        debug!("Reading local SSH keys from: {:?}", self.ssh_dir);
        let mut keys = Vec::new();
        for entry in fs::read_dir(&self.ssh_dir)
            .map_err(|e| format!("Failed to read SSH directory: {}", e))?
        {
            let entry = entry.map_err(|e| format!("Failed to read directory entry: {}", e))?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("pub") {
                trace!("Reading public key file: {:?}", path);
                let mut content = String::new();
                File::open(&path)
                    .and_then(|mut f| f.read_to_string(&mut content))
                    .map_err(|e| format!("Failed to read public key file: {}", e))?;
                keys.push(content.trim().to_string());
            }
        }
        debug!("Read {} local SSH keys", keys.len());
        Ok(keys)
    }

    fn update_local_keys(&self, sops_keys: &[String]) -> Result<(), String> {
        info!("Updating local SSH keys");
        for (i, key) in sops_keys.iter().enumerate() {
            let file_name = format!("id_ed25519_{}.pub", i + 1);
            let file_path = self.ssh_dir.join(&file_name);
            debug!("Writing key to file: {:?}", file_path);
            fs::write(&file_path, key)
                .map_err(|e| format!("Failed to write key to {}: {}", file_name, e))?;
        }
        info!("Local SSH keys updated successfully");
        Ok(())
    }

    fn add_to_sops(&self, name: &str, description: Option<&str>) -> Result<(), String> {
        info!("Adding SSH key to SOPS: {}", name);
        let pub_key_path = self.ssh_dir.join(format!("{}.pub", name));
        let pub_key = fs::read_to_string(&pub_key_path)
            .map_err(|e| format!("Failed to read public key: {}", e))?;

        let mut sops_content = self.read_sops_keys()?;
        sops_content.push(format!(
            "{}{}",
            pub_key.trim(),
            description.map(|d| format!(" # {}", d)).unwrap_or_default()
        ));

        self.write_sops_keys(&sops_content)
    }

    fn remove_from_sops(&self, name: &str) -> Result<(), String> {
        info!("Removing SSH key from SOPS: {}", name);
        let mut sops_content = self.read_sops_keys()?;
        let initial_count = sops_content.len();
        sops_content.retain(|key| !key.contains(&format!("{}.pub", name)));
        let removed_count = initial_count - sops_content.len();
        debug!("Removed {} key(s) from SOPS", removed_count);
        self.write_sops_keys(&sops_content)
    }

    fn write_sops_keys(&self, keys: &[String]) -> Result<(), String> {
        info!("Writing updated keys to SOPS file");

        let decrypted_content = self.decrypt_sops_file()?;

        let mut yaml: serde_yaml::Value = serde_yaml::from_str(&decrypted_content)
            .map_err(|e| format!("Failed to parse decrypted YAML: {}", e))?;

        if keys.is_empty() {
            // If there are no keys, remove the ssh_keys section entirely
            if let Some(map) = yaml.as_mapping_mut() {
                map.remove(&serde_yaml::Value::String("ssh_keys".to_string()));
            }
        } else {
            // If there are keys, update or create the ssh_keys section
            let ssh_keys = yaml
                .as_mapping_mut()
                .ok_or("Invalid YAML structure")?
                .entry(serde_yaml::Value::String("ssh_keys".to_string()))
                .or_insert(serde_yaml::Value::Mapping(serde_yaml::Mapping::new()))
                .as_mapping_mut()
                .ok_or("ssh_keys is not a mapping")?;

            ssh_keys.clear();
            for (i, key) in keys.iter().enumerate() {
                ssh_keys.insert(
                    serde_yaml::Value::String(format!("key_{}", i + 1)),
                    serde_yaml::Value::String(key.clone()),
                );
            }
        }

        let updated_content =
            serde_yaml::to_string(&yaml).map_err(|e| format!("Failed to serialize YAML: {}", e))?;

        self.encrypt_sops_file(&updated_content)
    }

    fn decrypt_sops_file(&self) -> Result<String, String> {
        let output = CheckedCommand::new("sops")
            .map_err(|e| format!("Failed to create SOPS command: {}", e))?
            .arg("-d")
            .arg(&self.sops_file)
            .output()
            .map_err(|e| format!("Failed to run SOPS decrypt: {}", e))?;

        if !output.status.success() {
            let err_msg = String::from_utf8_lossy(&output.stderr);
            return Err(format!("SOPS decryption failed: {}", err_msg));
        }

        String::from_utf8(output.stdout)
            .map_err(|e| format!("Failed to parse decrypted content: {}", e))
    }

    fn encrypt_sops_file(&self, content: &str) -> Result<(), String> {
        let mut child = CheckedCommand::new("sops")
            .map_err(|e| format!("Failed to create SOPS command: {}", e))?
            .arg("-e")
            .arg("-i")
            .arg(&self.sops_file)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()
            .map_err(|e| format!("Failed to start SOPS encrypt: {}", e))?;

        {
            let stdin = child
                .stdin
                .as_mut()
                .ok_or_else(|| "Failed to open stdin".to_string())?;
            stdin
                .write_all(content.as_bytes())
                .map_err(|e| format!("Failed to write to SOPS stdin: {}", e))?;
        }

        let output = child
            .wait_with_output()
            .map_err(|e| format!("Failed to wait for SOPS: {}", e))?;

        if !output.status.success() {
            let err_msg = String::from_utf8_lossy(&output.stderr);
            return Err(format!("SOPS encryption failed: {}", err_msg));
        }

        info!("SSH keys updated in SOPS file successfully");
        println!("{}", "SSH keys updated in SOPS file successfully.".green());
        Ok(())
    }

    fn get_last_modified(&self, path: &Path) -> Result<String, String> {
        trace!("Getting last modified time for: {:?}", path);
        let metadata = fs::metadata(path)
            .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?;

        let modified: DateTime<Local> = metadata
            .modified()
            .map_err(|e| format!("Failed to get modification time: {}", e))?
            .into();

        Ok(modified.format("%Y-%m-%d %H:%M:%S %z").to_string())
    }

    fn get_local_keys_last_modified(&self) -> Result<String, String> {
        let mut latest_modified: Option<DateTime<Local>> = None;

        for entry in fs::read_dir(&self.ssh_dir)
            .map_err(|e| format!("Failed to read SSH directory: {}", e))?
        {
            let entry = entry.map_err(|e| format!("Failed to read directory entry: {}", e))?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("pub") {
                let modified = self.get_last_modified(&path)?;
                let modified_date = DateTime::parse_from_str(&modified, "%Y-%m-%d %H:%M:%S %z")
                    .map_err(|e| format!("Failed to parse date: {}", e))?
                    .with_timezone(&Local);
                if latest_modified.is_none() || modified_date > latest_modified.unwrap() {
                    latest_modified = Some(modified_date);
                }
            }
        }

        latest_modified
            .map(|dt| dt.format("%Y-%m-%d %H:%M:%S").to_string())
            .ok_or_else(|| "No public keys found in SSH directory".to_string())
    }
}
