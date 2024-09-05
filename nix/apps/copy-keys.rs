#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dirs = "5.0"
//! regex = "1.5"
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
use std::path::Path;
use std::process::{Command, exit};

fn handle_no_usb() {
    eprintln!("{}", "No USB drive found or mounted.".red());
    println!("{}", "If you have not yet set up your keys, run the script to generate new SSH keys.".green());
    exit(1);
}

fn mount_usb() -> Option<String> {
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
        if let Some(mount_point) = info.lines()
            .find(|line| line.contains("Mount Point"))
            .and_then(|line| line.split(':').nth(1))
            .map(|s| s.trim().to_string())
        {
            if !mount_point.is_empty() {
                println!("{}", format!("USB drive found at {}.", mount_point).green());
                return Some(mount_point);
            }
        }
    }

    eprintln!("{}", "No USB drive found.".red());
    None
}

fn copy_keys(mount_path: &str, ssh_dir: &Path) -> std::io::Result<()> {
    fs::copy(format!("{}/id_ed25519_agenix.pub", mount_path), ssh_dir.join("id_ed25519_agenix.pub"))?;
    fs::copy(format!("{}/id_ed25519_agenix", mount_path), ssh_dir.join("id_ed25519_agenix"))?;
    fs::set_permissions(ssh_dir.join("id_ed25519_agenix"), fs::Permissions::from_mode(0o600))?;
    fs::set_permissions(ssh_dir.join("id_ed25519_agenix.pub"), fs::Permissions::from_mode(0o600))?;
    Ok(())
}

fn setup_ssh_directory(ssh_dir: &Path) -> std::io::Result<()> {
    fs::create_dir_all(ssh_dir)
}

fn set_keys(mount_path: &str, ssh_dir: &Path) -> std::io::Result<()> {
    fs::copy(format!("{}/id_ed25519_github.pub", mount_path), ssh_dir.join("id_ed25519.pub"))?;
    fs::copy(format!("{}/id_ed25519_github", mount_path), ssh_dir.join("id_ed25519"))?;
    fs::set_permissions(ssh_dir.join("id_ed25519"), fs::Permissions::from_mode(0o600))?;
    fs::set_permissions(ssh_dir.join("id_ed25519.pub"), fs::Permissions::from_mode(0o644))?;
    Ok(())
}

fn change_ownership(ssh_dir: &Path, username: &str) -> std::io::Result<()> {
    let files = ["id_ed25519", "id_ed25519.pub", "id_ed25519_agenix", "id_ed25519_agenix.pub"];
    for file in &files {
        let file_path = ssh_dir.join(file).to_string_lossy().into_owned();
        Command::new("chown")
            .args(&[&format!("{}:staff", username), &file_path])
            .status()?;
    }
    Ok(())
}

fn main() -> std::io::Result<()> {
    let username = env::var("USER").expect("Failed to get username");
    let ssh_dir = home_dir().unwrap().join(".ssh");

    setup_ssh_directory(&ssh_dir)?;

    if let Some(mount_path) = mount_usb() {
        copy_keys(&mount_path, &ssh_dir)?;
        set_keys(&mount_path, &ssh_dir)?;
        change_ownership(&ssh_dir, &username)?;
        println!("{}", "SSH keys successfully copied and set up.".green());
    } else {
        handle_no_usb();
    }

    Ok(())
}