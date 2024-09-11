#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
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
use dirs::home_dir;
use std::path::PathBuf;

#[path = "shared/config.rs"]
#[allow(dead_code)]
mod shared;

fn lint_keys(ssh_dir: &PathBuf, wg_dir: &PathBuf) {
    println!("{}", "=== SSH and WireGuard Key Checker ===".bold().blue());
    println!("Checking SSH keys in: {}", ssh_dir.display());
    println!("Checking WireGuard keys in: {}", wg_dir.display());

    let keys = match shared::Config::load() {
        Ok(config) => config.keys,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            std::process::exit(1);
        }
    };

    // Check SSH keys
    let mut missing_ssh_keys = Vec::new();
    println!("\n{}", "SSH Key Status:".bold().yellow());
    for key in &keys.ssh {
        let key_path = ssh_dir.join(key);
        if key_path.exists() {
            println!("  {}: {}", "Present".green(), key);
        } else {
            println!("  {}: {}", "Missing".red(), key);
            missing_ssh_keys.push(key);
        }
    }

    // Check WireGuard keys
    let mut missing_wg_keys = Vec::new();
    if let Some(ref wg_keys) = keys.wg {
        println!("\n{}", "WireGuard Key Status:".bold().yellow());
        for key in wg_keys {
            let key_path = wg_dir.join(key);
            if key_path.exists() {
                println!("  {}: {}", "Present".green(), key);
            } else {
                println!("  {}: {}", "Missing".red(), key);
                missing_wg_keys.push(key);
            }
        }
    }

    // Summary
    if missing_ssh_keys.is_empty() && missing_wg_keys.is_empty() {
        println!(
            "\n{}",
            "All SSH and WireGuard keys are present.".bold().green()
        );
    } else {
        println!("\n{}", "Some keys are missing:".bold().red());
        if !missing_ssh_keys.is_empty() {
            println!("\n{}", "Missing SSH Keys:".bold().red());
            for key in missing_ssh_keys {
                println!("  {}", key);
            }
        }
        if !missing_wg_keys.is_empty() {
            println!("\n{}", "Missing WireGuard Keys:".bold().red());
            for key in missing_wg_keys {
                println!("  {}", key);
            }
        }
        println!(
            "\n{}",
            "Run the create-keys command to generate the missing keys.".yellow()
        );
        std::process::exit(1);
    }
}

fn main() {
    let ssh_dir = home_dir()
        .expect("Failed to get home directory")
        .join(".ssh");

    let wg_dir = home_dir()
        .expect("Failed to get home directory")
        .join(".wireguard");

    lint_keys(&ssh_dir, &wg_dir);
}
