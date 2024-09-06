#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dialoguer = "0.10.3"
//! dirs = "5.0"
//! tempfile = "3.2.0"
//! which = "4.0.2"
//! ```

use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

use colored::*;
use dialoguer::{Confirm, Input};
use dirs::home_dir;
use tempfile::NamedTempFile;

// Function to check if a tool exists
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

// Function to ask user if they want to overwrite the existing key or skip
fn prompt_overwrite(file_path: &Path) -> io::Result<bool> {
    if file_path.exists() {
        println!("{} {} exists.", "Notice:".bold().yellow(), file_path.display());
        let overwrite = Confirm::new()
            .with_prompt("Do you want to overwrite the existing key?")
            .default(false)
            .interact()?;
        Ok(overwrite)
    } else {
        Ok(true)
    }
}

use std::process::{ Stdio};

fn generate_wireguard_keys(wg_dir: &Path, private_key_name: &str, public_key_name: &str) -> io::Result<()> {
    // Ensure the WireGuard directory exists
    fs::create_dir_all(wg_dir)?;

    // Create temporary files for private and public keys
    let mut private_key_file = NamedTempFile::new()?;
    let mut public_key_file = NamedTempFile::new()?;

    // Generate the private key
    let private_key_output = Command::new("wg")
        .arg("genkey")
        .output()?;

    if !private_key_output.status.success() {
        eprintln!("Failed to generate private key: {:?}", String::from_utf8_lossy(&private_key_output.stderr));
        return Err(io::Error::new(io::ErrorKind::Other, "Failed to generate private key"));
    }

    private_key_file.write_all(&private_key_output.stdout)?;

    // Generate the public key from the private key
    let private_key_path = private_key_file.path();
    let public_key_output = Command::new("wg")
        .arg("pubkey")
        .stdin(Stdio::from(fs::File::open(private_key_path)?))
        .output()?;

    if !public_key_output.status.success() {
        eprintln!("Failed to generate public key: {:?}", String::from_utf8_lossy(&public_key_output.stderr));
        return Err(io::Error::new(io::ErrorKind::Other, "Failed to generate public key"));
    }

    public_key_file.write_all(&public_key_output.stdout)?;

    // Move the keys to the target location
    fs::copy(private_key_file.path(), wg_dir.join(private_key_name))?;
    fs::copy(public_key_file.path(), wg_dir.join(public_key_name))?;

    println!("Private key saved to {}", wg_dir.join(private_key_name).display());
    println!("Public key saved to {}", wg_dir.join(public_key_name).display());

    Ok(())
}


fn main() -> io::Result<()> {
    println!("{}", "=== WireGuard Key Generator ===".bold().blue());

    let wg_dir = home_dir()
        .expect("Failed to get home directory")
        .join(".wireguard");

    // Create the WireGuard directory if it doesn't exist
    fs::create_dir_all(&wg_dir)?;

    // Prompt user for custom key filenames (optional)
    let private_key_name: String = Input::new()
        .with_prompt("Enter the private key filename (or press Enter for default)")
        .default("wg_private.key".to_string())
        .interact_text()?;

    let public_key_name: String = Input::new()
        .with_prompt("Enter the public key filename (or press Enter for default)")
        .default("wg_public.key".to_string())
        .interact_text()?;

    // Generate WireGuard keys with interactive handling of existing files
    generate_wireguard_keys(&wg_dir, &private_key_name, &public_key_name)?;

    println!("{}", "=== WireGuard Key Generation Complete ===".bold().green());

    Ok(())
}
