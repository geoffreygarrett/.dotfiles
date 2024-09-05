#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dialoguer = "0.10.3"
//! dirs = "5.0"
//! comfy-table = "6.1"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/
use comfy_table::*;
use colored::*;
use dialoguer::{Confirm, Password};
use dirs::home_dir;
use std::fs::{self};
use std::io::{self};
use std::path::{Path, PathBuf};
use std::process::Command;

fn setup_ssh_directory() -> io::Result<PathBuf> {
    let ssh_dir = home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Home directory not found"))?
        .join(".ssh");
    fs::create_dir_all(&ssh_dir)?;
    Ok(ssh_dir)
}

fn prompt_for_key_generation(key_path: &Path) -> io::Result<bool> {
    if key_path.exists() {
        println!("{}", format!("Existing SSH key found: {}", key_path.display()).yellow());
        if let Ok(public_key) = fs::read_to_string(key_path.with_extension("pub")) {
            println!("{}", public_key);
        }
        Confirm::new()
            .with_prompt("Do you want to replace it?")
            .default(false)
            .interact()
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))
    } else {
        Ok(true)
    }
}


fn print_key_status_table(key_statuses: &[(&str, bool)]) {
    let mut table = Table::new();
    table
        .set_header(vec!["Key Name", "Status"])
        .load_preset(comfy_table::presets::UTF8_FULL)
        .apply_modifier(comfy_table::modifiers::UTF8_ROUND_CORNERS)
        .set_content_arrangement(ContentArrangement::Dynamic)
        .set_width(60);

    for (key_name, generated) in key_statuses {
        let status = if *generated {
            Cell::new("Generated").fg(comfy_table::Color::Green)
        } else {
            Cell::new("Kept Existing").fg(comfy_table::Color::Yellow)
        };
        table.add_row(vec![Cell::new(*key_name), status]);
    }

    println!("\n{}", "SSH Key Generation Summary:".bold());
    println!("{table}");
}



fn generate_key(ssh_dir: &Path, key_name: &str) -> io::Result<bool> {
    let key_path = ssh_dir.join(key_name);

    if prompt_for_key_generation(&key_path)? {
        let use_passphrase = Confirm::new()
            .with_prompt("Do you want to use a passphrase for this key?")
            .default(true)
            .interact()
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?;

        let passphrase = if use_passphrase {
            Password::new()
                .with_prompt("Enter your passphrase")
                .with_confirmation("Repeat passphrase", "Passphrases do not match")
                .interact()
                .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?
        } else {
            String::new()
        };

        let output = Command::new("ssh-keygen")
            .args(&["-t", "ed25519", "-f", key_path.to_str().unwrap(), "-N", &passphrase])
            .output()?;

        if !output.status.success() {
            return Err(io::Error::new(io::ErrorKind::Other, String::from_utf8_lossy(&output.stderr)));
        }

        println!("{}", format!("Generated new key: {}", key_path.display()).green());

        if use_passphrase {
            println!("{}", "Remember your passphrase or store it securely.".yellow());
        }
        Ok(true)
    } else {
        println!("{}", format!("Kept existing key: {}", key_path.display()).green());
        Ok(false)
    }
}

fn display_public_keys(ssh_dir: &Path, key_names: &[&str]) -> io::Result<()> {
    for key_name in key_names {
        let public_key_path = ssh_dir.join(format!("{}.pub", key_name));
        if let Ok(public_key) = fs::read_to_string(public_key_path) {
            println!("{}", format!("{} public key:", key_name).cyan());
            println!("{}", public_key);
        }
    }
    Ok(())
}

fn main() -> io::Result<()> {
    println!("{}", "Interactive SSH Key Generator".bold());

    let ssh_dir = setup_ssh_directory()?;

    let key_names = ["id_ed25519", "id_ed25519_agenix"];
    let mut key_statuses = Vec::new();

    for key_name in &key_names {
        let generated = generate_key(&ssh_dir, key_name)?;
        key_statuses.push((*key_name, generated));
    }

    print_key_status_table(&key_statuses);

    println!("\n{}", "Remember to add the necessary keys to Github or other services as required.".green());

    if Confirm::new()
        .with_prompt("Do you want to display your public keys?")
        .interact()
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?
    {
        display_public_keys(&ssh_dir, &key_names)?;
    }

    Ok(())
}