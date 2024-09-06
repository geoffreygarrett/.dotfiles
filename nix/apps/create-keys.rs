#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dialoguer = "0.10.3"
//! dirs = "5.0"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.5"
//! tempfile = "3.2.0"
//! which = "4.0.2"
//! ```
use colored::*;
use dialoguer::{Confirm, Password};
use dirs::home_dir;
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, exit};
use tempfile::NamedTempFile;

#[path = "shared/config.rs"]
#[allow(dead_code)]
mod shared;

// Function to set up the SSH or WireGuard directory
fn setup_directory(dir_name: &str) -> io::Result<PathBuf> {
    let dir = home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Home directory not found"))?
        .join(dir_name);
    fs::create_dir_all(&dir)?;
    Ok(dir)
}

// Function to check if a tool exists, otherwise print a stylized error message
fn check_tool_exists(tool: &str) -> io::Result<()> {
    if which::which(tool).is_err() {
        eprintln!(
            "{} {} {}",
            "Error:".bold().red(),
            tool.bold().yellow(),
            "not found. Please install it to proceed.".red()
        );
        Err(io::Error::new(
            io::ErrorKind::NotFound,
            format!("{} not found.", tool),
        ))
    } else {
        Ok(())
    }
}

// Prompt the user if they want to regenerate the key if it already exists
fn prompt_for_key_generation(key_path: &Path) -> io::Result<bool> {
    if key_path.exists() {
        println!("  {}: {}", "Existing".yellow(), key_path.display());
        Confirm::new()
            .with_prompt("  Do you want to replace it?")
            .default(false)
            .interact()
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))
    } else {
        Ok(true)
    }
}

// Generate SSH keys using ssh-keygen
fn generate_ssh_key(ssh_dir: &Path, key_name: &str) -> io::Result<bool> {
    // Ensure ssh-keygen is available
    check_tool_exists("ssh-keygen")?;

    let key_path = ssh_dir.join(key_name);

    if prompt_for_key_generation(&key_path)? {
        let use_passphrase = Confirm::new()
            .with_prompt("  Do you want to use a passphrase for this key?")
            .default(true)
            .interact()
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?;

        let passphrase = if use_passphrase {
            Password::new()
                .with_prompt("  Enter your passphrase")
                .with_confirmation("  Repeat passphrase", "  Passphrases do not match")
                .interact()
                .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?
        } else {
            String::new()
        };

        let output = if cfg!(target_os = "windows") {
            Command::new("ssh-keygen.exe")
        } else {
            Command::new("ssh-keygen")
        }
            .args(&["-t", "ed25519", "-f", key_path.to_str().unwrap(), "-N", &passphrase])
            .output()?;

        if !output.status.success() {
            return Err(io::Error::new(io::ErrorKind::Other, String::from_utf8_lossy(&output.stderr)));
        }

        println!("  {}: {}", "Generated".green(), key_path.display());
        if use_passphrase {
            println!("  {}", "Remember your passphrase or store it securely.".yellow());
        }
        Ok(true)
    } else {
        println!("  {}: {}\n", "Kept".yellow(), key_path.display());
        Ok(false)
    }
}

// Generate WireGuard keys using the wg tool
fn generate_wireguard_keys(wg_dir: &Path, private_key_name: &str, public_key_name: &str) -> io::Result<()> {
    // Ensure wg command is available
    check_tool_exists("wg")?;

    let private_key_path = wg_dir.join(private_key_name);
    let public_key_path = wg_dir.join(public_key_name);

    if prompt_for_key_generation(&private_key_path)? {
        // Generate WireGuard private key
        let output = Command::new("wg")
            .arg("genkey")
            .output()?;

        if !output.status.success() {
            return Err(io::Error::new(io::ErrorKind::Other, String::from_utf8_lossy(&output.stderr)));
        }

        let private_key = String::from_utf8_lossy(&output.stdout).trim().to_string();
        fs::write(&private_key_path, &private_key)?;

        // Generate WireGuard public key using a temp file for the private key
        let mut temp_file = NamedTempFile::new()?;
        writeln!(temp_file, "{}", private_key)?;

        let output = Command::new("wg")
            .arg("pubkey")
            .stdin(fs::File::open(temp_file.path())?)
            .output()?;

        if !output.status.success() {
            return Err(io::Error::new(io::ErrorKind::Other, String::from_utf8_lossy(&output.stderr)));
        }

        let public_key = String::from_utf8_lossy(&output.stdout).trim().to_string();
        fs::write(&public_key_path, public_key)?;

        println!("  {}: {}", "Generated WireGuard keys".green(), private_key_path.display());
    } else {
        println!("  {}: {}\n", "Kept".yellow(), private_key_path.display());
    }

    Ok(())
}

// Display SSH public keys
fn display_public_keys(ssh_dir: &Path, key_names: &[String]) -> io::Result<()> {
    println!("\n{}", "Public Keys:".bold().cyan());
    for key_name in key_names {
        let public_key_path = ssh_dir.join(format!("{}.pub", key_name));
        if let Ok(public_key) = fs::read_to_string(public_key_path) {
            println!("  {}:", key_name.cyan());
            println!("  {}", public_key);
        }
    }
    Ok(())
}

fn main() -> io::Result<()> {
    println!("{}", "=== Interactive Key Generator ===".bold().blue());

    let config = match shared::Config::load() {
        Ok(config) => config,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            exit(1);
        }
    };

    let ssh_dir = setup_directory(".ssh")?;
    println!("Setting up SSH directory: {}", ssh_dir.display());

    let wg_dir = setup_directory(".wireguard")?;
    println!("Setting up WireGuard directory: {}", wg_dir.display());

    println!("\n{}", "Key Generation:".bold().yellow());
    for key_name in &config.keys.ssh {
        generate_ssh_key(&ssh_dir, key_name)?;
    }

    if let Some(ref wg_keys) = config.keys.wg {
        generate_wireguard_keys(&wg_dir, &wg_keys[0], &wg_keys[1])?;
    }

    println!("{}", "Key Generation Summary:".bold().green());
    for key_name in &config.keys.ssh {
        let key_path = ssh_dir.join(key_name);
        if key_path.exists() {
            println!("  {}: {}", "SSH Present".green(), key_name);
        } else {
            println!("  {}: {}", "SSH Missing".red(), key_name);
        }
    }

    if let Some(ref wg_keys) = config.keys.wg {
        let wg_private_key_path = wg_dir.join(&wg_keys[0]);
        let wg_public_key_path = wg_dir.join(&wg_keys[1]);
        if wg_private_key_path.exists() {
            println!("  {}: {}", "WireGuard Private Key Present".green(), wg_keys[0]);
        }
        if wg_public_key_path.exists() {
            println!("  {}: {}", "WireGuard Public Key Present".green(), wg_keys[1]);
        }
    }

    if Confirm::new()
        .with_prompt("Do you want to display your SSH public keys?")
        .default(true)
        .interact()
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?
    {
        display_public_keys(&ssh_dir, &config.keys.ssh)?;
    }

    println!("\n{}", "Key generation process completed successfully.".bold().green());

    Ok(())
}
