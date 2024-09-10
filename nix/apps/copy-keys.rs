#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dirs = "5.0"
//! regex = "1.5"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.5"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use colored::*;
use dirs::home_dir;
use regex::Regex;
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::{exit, Command};

#[path = "shared.rs"]
#[allow(dead_code)]
mod shared;

fn handle_no_usb() {
    eprintln!("{}", "No USB drive found or mounted.".red());
    println!(
        "{}",
        "If you have not yet set up your keys, run the script to generate new SSH keys.".yellow()
    );
    exit(1);
}

fn mount_usb() -> Option<PathBuf> {
    if cfg!(target_os = "macos") {
        mount_usb_macos()
    } else if cfg!(target_os = "linux") {
        mount_usb_linux()
    } else {
        eprintln!("{}", "Unsupported operating system".red());
        None
    }
}

fn mount_usb_macos() -> Option<PathBuf> {
    let output = Command::new("diskutil")
        .arg("list")
        .output()
        .expect("Failed to execute diskutil command");

    let disk_list = String::from_utf8_lossy(&output.stdout);
    let re = Regex::new(r"disk[0-9]").unwrap();

    for disk in re.find_iter(&disk_list) {
        let info_output = Command::new("diskutil")
            .args(&["info", &format!("/dev/{}", disk.as_str())])
            .output()
            .expect("Failed to execute diskutil info command");

        let info = String::from_utf8_lossy(&info_output.stdout);
        if let Some(mount_point) = info
            .lines()
            .find(|line| line.contains("Mount Point"))
            .and_then(|line| line.split(':').nth(1))
            .map(|s| s.trim().to_string())
        {
            if !mount_point.is_empty() {
                println!("{}", format!("USB drive found at {}.", mount_point).green());
                return Some(PathBuf::from(mount_point));
            }
        }
    }

    eprintln!("{}", "No USB drive found.".red());
    None
}

fn mount_usb_linux() -> Option<PathBuf> {
    let output = Command::new("lsblk")
        .args(&["-nlo", "NAME,MOUNTPOINT"])
        .output()
        .expect("Failed to execute lsblk command");

    let mount_list = String::from_utf8_lossy(&output.stdout);
    for line in mount_list.lines() {
        let parts: Vec<&str> = line.split_whitespace().collect();
        if parts.len() == 2 && parts[1].starts_with("/media/") {
            println!("{}", format!("USB drive found at {}.", parts[1]).green());
            return Some(PathBuf::from(parts[1]));
        }
    }

    eprintln!("{}", "No USB drive found.".red());
    None
}

fn copy_keys(mount_path: &Path, ssh_dir: &Path) -> std::io::Result<Vec<String>> {
    let config = match shared::Config::load() {
        Ok(config) => config,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            std::process::exit(1);
        }
    };
    let mut copied_files = Vec::new();

    println!("\n{}", "Copying SSH Keys:".bold().green());
    for key in &config.keys.ssh {
        let src_path = mount_path.join(key);
        let dest_path = ssh_dir.join(key);

        if !src_path.exists() {
            println!("  {}: {}", "Not found".red(), key);
            continue;
        }

        match fs::copy(&src_path, &dest_path) {
            Ok(_) => {
                println!("  {}: {} -> {}", "Copied".green(), key, dest_path.display());
                copied_files.push(key.to_string());

                let permissions = if key.ends_with(".pub") { 0o644 } else { 0o600 };
                if let Err(e) =
                    fs::set_permissions(&dest_path, fs::Permissions::from_mode(permissions))
                {
                    println!(
                        "  {}: Failed to set permissions for {}: {}",
                        "Warning".yellow(),
                        key,
                        e
                    );
                }
            }
            Err(e) => println!("  {}: Failed to copy {}: {}", "Error".red(), key, e),
        }
    }

    Ok(copied_files)
}

fn setup_ssh_directory(ssh_dir: &Path) -> std::io::Result<()> {
    fs::create_dir_all(ssh_dir)
}

fn change_ownership(ssh_dir: &Path, username: &str) -> std::io::Result<()> {
    let config = match shared::Config::load() {
        Ok(config) => config,
        Err(e) => {
            eprintln!("{}", format!("Failed to load configuration: {}", e).red());
            std::process::exit(1);
        }
    };

    println!("\n{}", "Changing Ownership:".bold().cyan());
    for key in &config.keys.ssh {
        let file_path = ssh_dir.join(key);
        if file_path.exists() {
            let file_path_str = file_path.to_str().unwrap_or_default();
            if cfg!(target_os = "macos") {
                Command::new("chown")
                    .args(&[&format!("{}:staff", username), file_path_str])
                    .status()?;
            } else if cfg!(target_os = "linux") {
                Command::new("chown")
                    .args(&[username, file_path_str])
                    .status()?;
            }
            println!("  {}: {}", "Changed ownership".green(), file_path_str);
        } else {
            println!("  {}: {} (file not found)", "Skipped".yellow(), key);
        }
    }
    Ok(())
}

fn main() -> std::io::Result<()> {
    println!("{}", "=== SSH Key Setup Script ===".bold().blue());

    let username = env::var("USER").expect("Failed to get username");
    let ssh_dir = home_dir().unwrap().join(".ssh");

    println!("Setting up SSH directory: {}", ssh_dir.display());
    setup_ssh_directory(&ssh_dir)?;

    if let Some(mount_path) = mount_usb() {
        println!("\n{}", "USB Drive Contents:".bold().yellow());
        for entry in fs::read_dir(&mount_path)? {
            if let Ok(entry) = entry {
                println!("  {}", entry.path().file_name().unwrap().to_string_lossy());
            }
        }

        copy_keys(&mount_path, &ssh_dir)?;
        change_ownership(&ssh_dir, &username)?;

        println!(
            "\n{}",
            "SSH keys setup process completed successfully."
                .bold()
                .green()
        );
        println!("Your keys should now be set up in: {}", ssh_dir.display());
    } else {
        handle_no_usb();
    }

    Ok(())
}
