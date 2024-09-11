use std::fs::{self, File, OpenOptions};
use std::io::{Read, Write};
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result};
use clap::{Args, Subcommand};
use colored::*;
use serde::{Deserialize, Serialize};
use serde_yaml;
use thiserror::Error;

#[derive(Debug, Serialize, Deserialize)]
struct SopsConfig {
    keys: Option<Vec<String>>,
    creation_rules: Vec<CreationRule>,
}

#[derive(Debug, Serialize, Deserialize)]
struct CreationRule {
    path_regex: String,
    key_groups: Vec<KeyGroup>,
}

#[derive(Debug, Serialize, Deserialize)]
struct KeyGroup {
    age: Vec<String>,
}

#[derive(Error, Debug)]
enum SopsError {
    #[error("Failed to generate SSH key")]
    SshKeyGeneration,
    #[error("Failed to convert SSH key to age key")]
    SshToAgeConversion,
    #[error("Failed to read or write SOPS config")]
    SopsConfigIO,
    #[error("Failed to parse SOPS config")]
    SopsConfigParse,
    #[error("Failed to create directory")]
    DirectoryCreation,
    #[error("Failed to generate age key")]
    AgeKeyGeneration,
}

#[derive(Subcommand, Clone)]
pub enum SecretsCommands {
    /// Sync public SSH keys to age keys in SOPS config
    #[clap(name = "sync-public-key")]
    SyncPublicKeys {
        /// Path to the SSH key (default: ~/.ssh/id_ed25519)
        #[arg(long, short = 'k')]
        ssh_key_path: Option<PathBuf>,

        /// Path to the SOPS config file (default: .sops.yaml)
        #[arg(long, short = 'c')]
        config_path: Option<PathBuf>,
    },
}

#[derive(Args)]
pub struct SecretsArgs {
    #[command(subcommand)]
    pub command: SecretsCommands,
}

fn generate_ssh_key(key_path: &Path) -> Result<(), SopsError> {
    if !key_path.exists() {
        println!("{}", "Generating new SSH key...".yellow());
        Command::new("ssh-keygen")
            .args(&["-t", "ed25519", "-f", key_path.to_str().unwrap(), "-N", ""])
            .output()
            .map_err(|_| SopsError::SshKeyGeneration)?;
        println!("{}", "SSH key generated successfully.".green());
    } else {
        println!("{}", "SSH key already exists.".yellow());
    }
    Ok(())
}

// When decrypting a file with the corresponding identity, SOPS will look for a text file named keys.txt
// located in a sops subdirectory of your user configuration directory.
// On Linux, this would be $XDG_CONFIG_HOME/sops/age/keys.txt. If $XDG_CONFIG_HOME is not set $HOME/.config/sops/age/keys.txt is used instead.
// On macOS, this would be $HOME/Library/Application Support/sops/age/keys.txt.
// On Windows, this would be %AppData%\sops\age\keys.txt.
// You can specify the location of this file manually by setting the environment variable SOPS_AGE_KEY_FILE.
// Alternatively, you can provide the key(s) directly by setting the SOPS_AGE_KEY environment variable.
// For more information, see: https://github.com/getsops/sops?tab=readme-ov-file#22encrypting-using-age

fn get_age_key_path() -> PathBuf {
    if let Ok(path) = std::env::var("SOPS_AGE_KEY_FILE") {
        PathBuf::from(path)
    } else {
        let base_path = if cfg!(target_os = "windows") {
            dirs::data_local_dir().expect("Could not determine AppData directory")
        } else if cfg!(target_os = "macos") {
            dirs::home_dir()
                .expect("Could not determine home directory")
                .join("Library")
                .join("Application Support")
        } else {
            // Linux and other Unix-like systems
            dirs::config_dir().unwrap_or_else(|| {
                dirs::home_dir()
                    .expect("Could not determine home directory")
                    .join(".config")
            })
        };
        base_path.join("sops").join("age").join("keys.txt")
    }
}

fn generate_or_get_age_key(ssh_key_path: &Path, age_key_path: &Path) -> Result<(String, String), SopsError> {
    // Ensure the directory exists
    if let Some(parent) = age_key_path.parent() {
        fs::create_dir_all(parent).map_err(|_| SopsError::DirectoryCreation)?;
    }

    if age_key_path.exists() {
        println!("{}", "Age key already exists. Reading existing key...".yellow());
        let age_key = fs::read_to_string(age_key_path).map_err(|_| SopsError::SopsConfigIO)?;
        let public_key = extract_public_key(&age_key)?;
        return Ok((age_key, public_key));
    }

    println!("{}", "Generating new age key...".yellow());

    // Generate age key
    let output = Command::new("age-keygen")
        .arg("-o")
        .arg(age_key_path)
        .output()
        .map_err(|_| SopsError::AgeKeyGeneration)?;

    if !output.status.success() {
        return Err(SopsError::AgeKeyGeneration);
    }

    let age_key = fs::read_to_string(age_key_path).map_err(|_| SopsError::SopsConfigIO)?;
    let public_key = extract_public_key(&age_key)?;

    println!("{}", "Age key generated and saved successfully.".green());
    Ok((age_key, public_key))
}

fn extract_public_key(age_key: &str) -> Result<String, SopsError> {
    age_key
        .lines()
        .find(|line| line.starts_with("# public key: "))
        .map(|line| line.trim_start_matches("# public key: ").to_string())
        .ok_or(SopsError::AgeKeyGeneration)
}

fn update_sops_config(config_path: &Path, age_public_key: &str) -> Result<(), SopsError> {
    println!("{}", "Updating SOPS config...".yellow());
    let config = if config_path.exists() {
        let mut file = File::open(config_path).map_err(|_| SopsError::SopsConfigIO)?;
        let mut contents = String::new();
        file.read_to_string(&mut contents).map_err(|_| SopsError::SopsConfigIO)?;
        serde_yaml::from_str(&contents).map_err(|_| SopsError::SopsConfigParse)?
    } else {
        SopsConfig {
            keys: None,
            creation_rules: vec![CreationRule {
                path_regex: String::from(".*"),
                key_groups: vec![KeyGroup { age: Vec::new() }],
            }],
        }
    };

    let mut config: SopsConfig = config;

    let mut updated = false;
    for rule in &mut config.creation_rules {
        for key_group in &mut rule.key_groups {
            if !key_group.age.contains(&age_public_key.to_string()) {
                key_group.age.push(age_public_key.to_string());
                updated = true;
            }
        }
    }

    if updated {
        let updated_contents = serde_yaml::to_string(&config).map_err(|_| SopsError::SopsConfigParse)?;

        let mut file = OpenOptions::new()
            .write(true)
            .create(true)
            .truncate(true)
            .open(config_path)
            .map_err(|_| SopsError::SopsConfigIO)?;

        file.write_all(updated_contents.as_bytes()).map_err(|_| SopsError::SopsConfigIO)?;
        println!("{}", "SOPS config updated successfully.".green());
    } else {
        println!("{}", "Age key already exists in SOPS config. No changes made.".yellow());
    }

    Ok(())
}

pub fn run_secrets(args: SecretsArgs) -> Result<()> {
    match args.command {
        SecretsCommands::SyncPublicKeys { ssh_key_path, config_path } => {
            let home_dir = dirs::home_dir().context("Could not determine home directory")?;
            let default_ssh_dir = home_dir.join(".ssh");
            let ssh_key_path = ssh_key_path.unwrap_or_else(|| default_ssh_dir.join("id_ed25519"));
            let sops_config_path = config_path.unwrap_or_else(|| PathBuf::from(".sops.yaml"));

            // Get the correct age key path based on the operating system
            let age_key_path = get_age_key_path();

            generate_ssh_key(&ssh_key_path)?;

            let (age_key, age_public_key) = generate_or_get_age_key(&ssh_key_path, &age_key_path)?;

            println!("{} {}", "Age public key:".green(), age_public_key);

            update_sops_config(&sops_config_path, &age_public_key)?;
            println!("{} {:?}", "Updated SOPS config at".green(), sops_config_path);
            println!("{} {:?}", "Age private key saved at".green(), age_key_path);

            Ok(())
        }
    }
}