#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dialoguer = "0.10.3"
//! dirs = "5.0"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.5"
//! ```
//! ```rust
//! #[path = "shared.rs"]
//! mod shared;
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use colored::*;
use dialoguer::{Confirm, Password};
use dirs::home_dir;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::{exit, Command};

#[path = "shared.rs"]
#[allow(dead_code)]
mod shared;

fn setup_ssh_directory() -> io::Result<PathBuf> {
    let ssh_dir = home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Home directory not found"))?
        .join(".ssh");
    fs::create_dir_all(&ssh_dir)?;
    Ok(ssh_dir)
}

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

fn generate_key(ssh_dir: &Path, key_name: &str) -> io::Result<bool> {
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
    println!("{}", "=== Interactive SSH Key Generator ===".bold().blue());

    let keys = match shared::Config::load() {
        Ok(config) => config.keys.ssh,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            exit(1);
        }
    };

    let ssh_dir = setup_ssh_directory()?;
    println!("Setting up SSH directory: {}", ssh_dir.display());

    println!("\n{}", "Key Generation:".bold().yellow());
    for key_name in &keys {
        generate_key(&ssh_dir, key_name)?;
    }

    println!("{}", "Key Generation Summary:".bold().green());
    for key_name in &keys {
        let key_path = ssh_dir.join(key_name);
        if key_path.exists() {
            println!("  {}: {}", "Present".green(), key_name);
        } else {
            println!("  {}: {}", "Missing".red(), key_name);
        }
    }

    println!("\n{}", "Remember to add the necessary keys to Github or other services as required.".yellow());

    if Confirm::new()
        .with_prompt("Do you want to display your public keys?")
        .default(true)
        .interact()
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?
    {
        display_public_keys(&ssh_dir, &keys)?;
    }

    println!("\n{}", "SSH key generation process completed successfully.".bold().green());

    Ok(())
}
