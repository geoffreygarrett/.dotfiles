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

#[path = "shared.rs"]
#[allow(dead_code)]
mod shared;

fn lint_keys(ssh_dir: &PathBuf) {
    println!("{}", "=== SSH Key Checker ===".bold().blue());
    println!("Checking SSH keys in: {}", ssh_dir.display());

    let keys = match shared::Config::load() {
        Ok(config) => config.keys.ssh,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            std::process::exit(1);
        }
    };
    let mut missing_keys = Vec::new();

    println!("\n{}", "Key Status:".bold().yellow());
    for key in &keys {
        let key_path = ssh_dir.join(key);
        if key_path.exists() {
            println!("  {}: {}", "Present".green(), key);
        } else {
            println!("  {}: {}", "Missing".red(), key);
            missing_keys.push(key);
        }
    }

    if missing_keys.is_empty() {
        println!("\n{}", "All SSH keys are present.".bold().green());
    } else {
        println!("\n{}", "Some SSH keys are missing:".bold().red());
        for key in missing_keys {
            println!("  {}", key);
        }
        println!("\n{}", "Run the create-keys command to generate the missing keys.".yellow());
        std::process::exit(1);
    }
}

fn main() {
    let ssh_dir = home_dir()
        .expect("Failed to get home directory")
        .join(".ssh");

    lint_keys(&ssh_dir);
}
