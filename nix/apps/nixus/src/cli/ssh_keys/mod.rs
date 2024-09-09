use std::path::PathBuf;
use clap::{Args, Subcommand};

pub mod ssh_key_manager;
use ssh_key_manager::SshKeyManager;

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

pub fn run_ssh_keys(args: SshKeysArgs) -> Result<(), String> {
    match args.command {
        SshKeysCommand::Sync { path } => {
            let manager = SshKeyManager::new(path)?;
            manager.sync()
        }
        SshKeysCommand::Generate { name, description } => {
            let manager = SshKeyManager::new(None)?;
            manager.generate(&name, description.as_deref())
        }
        SshKeysCommand::Delete { name } => {
            let manager = SshKeyManager::new(None)?;
            manager.delete(&name)
        }
    }
}