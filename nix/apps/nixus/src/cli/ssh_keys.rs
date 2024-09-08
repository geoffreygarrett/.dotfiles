use std::fs::{self, File};
use std::io::{self, Read, Write};
use std::path::{Path, PathBuf};
use std::process::Command;

use chrono::{DateTime, Local};
use clap::{Args, Subcommand};
use colored::Colorize;
use serde_yaml;

#[derive(Args)]
pub struct SshKeysArgs {
    #[command(subcommand)]
    command: SshKeysCommand,
}

#[derive(Subcommand)]
pub enum SshKeysCommand {
    /// Sync and check SSH keys across devices
    Sync {
        /// Path to the SSH directory (optional)
        #[arg(short, long)]
        path: Option<PathBuf>,
    },
    /// Generate a new SSH key pair
    Generate {
        /// Name of the key file (default: id_ed25519)
        #[arg(short, long, default_value = "id_ed25519")]
        name: String,
        /// Description of the key (optional)
        #[arg(short, long)]
        description: Option<String>,
    },
    /// Delete an SSH key
    Delete {
        /// Name of the key file to delete
        name: String,
    },
}


struct SshKeyManager {
    ssh_dir: PathBuf,
    sops_file: PathBuf,
}

impl SshKeyManager {
    fn new(ssh_dir: Option<PathBuf>) -> Self {
        let ssh_dir = ssh_dir.unwrap_or_else(|| {
            dirs::home_dir()
                .expect("Could not find home directory")
                .join(".ssh")
        });
        let sops_file = Self::find_sops_file().expect("Could not find SOPS secrets file");
        Self { ssh_dir, sops_file }
    }

    fn find_sops_file() -> io::Result<PathBuf> {
        let current_dir = std::env::current_dir()?;
        let mut dir = current_dir.as_path();
        loop {
            let sops_file = dir.join("secrets.yaml");
            if sops_file.exists() {
                return Ok(sops_file);
            }
            if let Some(parent) = dir.parent() {
                dir = parent;
            } else {
                return Err(io::Error::new(io::ErrorKind::NotFound, "SOPS secrets file not found"));
            }
        }
    }

    fn sync(&self) -> Result<(), String> {
        println!("{}", "Syncing SSH keys...".yellow());

        let sops_keys = self.read_sops_keys()?;
        let local_keys = self.read_local_keys()?;

        if sops_keys == local_keys {
            println!("{}", "No changes detected. Keys are in sync.".green());
            return Ok(());
        }

        println!("Differences detected between local keys and SOPS secrets.");
        println!("Local keys last modified: {}", self.get_last_modified(&self.ssh_dir.join("id_ed25519.pub"))?);
        println!("SOPS secrets last modified: {}", self.get_last_modified(&self.sops_file)?);

        if ask_for_confirmation("Do you want to overwrite local keys with SOPS secrets?") {
            self.update_local_keys(&sops_keys)?;
            println!("{}", "Local keys updated successfully.".green());
        } else {
            println!("{}", "Sync cancelled. No changes made.".yellow());
        }

        Ok(())
    }

    fn generate(&self, name: &str, description: Option<&str>) -> Result<(), String> {
        println!("{}", "Generating new SSH key...".yellow());

        let key_path = self.ssh_dir.join(name);
        let output = Command::new("ssh-keygen")
            .arg("-t")
            .arg("ed25519")
            .arg("-f")
            .arg(&key_path)
            .arg("-N")
            .arg("")
            .output()
            .map_err(|e| format!("Failed to execute ssh-keygen: {}", e))?;

        if !output.status.success() {
            return Err(format!("ssh-keygen failed: {}", String::from_utf8_lossy(&output.stderr)));
        }

        println!("{}", "SSH key pair generated successfully.".green());
        println!("Private key: {}", key_path.display());
        println!("Public key: {}", key_path.with_extension("pub").display());

        self.add_to_sops(name, description)?;

        Ok(())
    }

    fn delete(&self, name: &str) -> Result<(), String> {
        println!("{}", format!("Deleting SSH key '{}'...", name).yellow());

        let key_path = self.ssh_dir.join(name);
        let pub_key_path = key_path.with_extension("pub");

        if !key_path.exists() && !pub_key_path.exists() {
            return Err(format!("No key found with name '{}'", name));
        }

        // Move to trash instead of permanent deletion
        if key_path.exists() {
            fs::rename(&key_path, self.ssh_dir.join("trash").join(name))
                .map_err(|e| format!("Failed to move private key to trash: {}", e))?;
        }
        if pub_key_path.exists() {
            fs::rename(&pub_key_path, self.ssh_dir.join("trash").join(format!("{}.pub", name)))
                .map_err(|e| format!("Failed to move public key to trash: {}", e))?;
        }

        self.remove_from_sops(name)?;

        println!("{}", format!("SSH key '{}' deleted successfully.", name).green());
        Ok(())
    }

    fn read_sops_keys(&self) -> Result<Vec<String>, String> {
        let output = Command::new("sops")
            .arg("-d")
            .arg(&self.sops_file)
            .output()
            .map_err(|e| format!("Failed to decrypt SOPS file: {}", e))?;

        if !output.status.success() {
            return Err(format!("SOPS decryption failed: {}", String::from_utf8_lossy(&output.stderr)));
        }

        let decrypted = String::from_utf8_lossy(&output.stdout);
        let yaml: serde_yaml::Value = serde_yaml::from_str(&decrypted)
            .map_err(|e| format!("Failed to parse YAML: {}", e))?;

        let ssh_keys = yaml["ssh_keys"].as_mapping()
            .ok_or("No ssh_keys found in SOPS file")?;

        Ok(ssh_keys.values()
            .filter_map(|v| v.as_str())
            .map(String::from)
            .collect())
    }

    fn read_local_keys(&self) -> Result<Vec<String>, String> {
        let mut keys = Vec::new();
        for entry in fs::read_dir(&self.ssh_dir).map_err(|e| format!("Failed to read SSH directory: {}", e))? {
            let entry = entry.map_err(|e| format!("Failed to read directory entry: {}", e))?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("pub") {
                let mut content = String::new();
                File::open(&path)
                    .and_then(|mut f| f.read_to_string(&mut content))
                    .map_err(|e| format!("Failed to read public key file: {}", e))?;
                keys.push(content.trim().to_string());
            }
        }
        Ok(keys)
    }

    fn update_local_keys(&self, sops_keys: &[String]) -> Result<(), String> {
        for (i, key) in sops_keys.iter().enumerate() {
            let file_name = format!("id_ed25519_{}.pub", i + 1);
            let file_path = self.ssh_dir.join(&file_name);
            fs::write(&file_path, key)
                .map_err(|e| format!("Failed to write key to {}: {}", file_name, e))?;
        }
        Ok(())
    }

    fn add_to_sops(&self, name: &str, description: Option<&str>) -> Result<(), String> {
        let pub_key_path = self.ssh_dir.join(format!("{}.pub", name));
        let pub_key = fs::read_to_string(&pub_key_path)
            .map_err(|e| format!("Failed to read public key: {}", e))?;

        let mut sops_content = self.read_sops_keys()?;
        sops_content.push(format!("{}{}", pub_key.trim(), description.map(|d| format!(" # {}", d)).unwrap_or_default()));

        self.write_sops_keys(&sops_content)
    }

    fn remove_from_sops(&self, name: &str) -> Result<(), String> {
        let mut sops_content = self.read_sops_keys()?;
        sops_content.retain(|key| !key.contains(&format!("{}.pub", name)));
        self.write_sops_keys(&sops_content)
    }

    fn write_sops_keys(&self, keys: &[String]) -> Result<(), String> {
        let keys_json = serde_json::to_string(keys)
            .map_err(|e| format!("Failed to serialize keys to JSON: {}", e))?;

        let output = Command::new("sops")
            .arg("edit")
            .arg(&self.sops_file)
            .arg(format!("['ssh_keys'] {}", keys_json))
            .output()
            .map_err(|e| format!("Failed to run SOPS: {}", e))?;

        if !output.status.success() {
            return Err(format!("SOPS edit failed: {}", String::from_utf8_lossy(&output.stderr)));
        }

        println!("{}", "SSH keys updated in SOPS file successfully.".green());
        Ok(())
    }
    fn get_last_modified(&self, path: &Path) -> Result<String, String> {
        let metadata = fs::metadata(path)
            .map_err(|e| format!("Failed to get metadata for {}: {}", path.display(), e))?;
        let modified: DateTime<Local> = metadata.modified()
            .map_err(|e| format!("Failed to get modification time: {}", e))?
            .into();
        Ok(modified.format("%Y-%m-%d %H:%M:%S").to_string())
    }
}

fn ask_for_confirmation(prompt: &str) -> bool {
    print!("{} [y/N]: ", prompt);
    io::stdout().flush().unwrap();
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    input.trim().to_lowercase() == "y"
}

pub fn run_ssh_keys(args: SshKeysArgs) -> Result<(), String> {
    match args.command {
        SshKeysCommand::Sync { path } => {
            let manager = SshKeyManager::new(path);
            manager.sync()
        }
        SshKeysCommand::Generate { name, description } => {
            let manager = SshKeyManager::new(None);
            manager.generate(&name, description.as_deref())
        }
        SshKeysCommand::Delete { name } => {
            let manager = SshKeyManager::new(None);
            manager.delete(&name)
        }
    }
}