#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! serde = { version = "1.0", features = ["derive"] }
//! serde_json = "1.0"
//! reqwest = { version = "0.11", features = ["blocking"] }
//! dirs = "4.0"
//! toml = "0.5"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

// Example 1: System Information Gatherer
fn gather_system_info() -> String {
    let hostname = std::process::Command::new("hostname")
        .output()
        .expect("Failed to execute hostname command")
        .stdout;
    let hostname = String::from_utf8_lossy(&hostname).trim().to_string();

    let kernel = std::process::Command::new("uname")
        .arg("-r")
        .output()
        .expect("Failed to execute uname command")
        .stdout;
    let kernel = String::from_utf8_lossy(&kernel).trim().to_string();

    format!("Hostname: {}\nKernel version: {}", hostname, kernel)
}

// Example 2: NixOS Configuration Parser
#[derive(Deserialize, Serialize)]
struct NixosConfig {
    system: SystemConfig,
}

#[derive(Deserialize, Serialize)]
struct SystemConfig {
    #[serde(rename = "stateVersion")]
    state_version: String,
    #[serde(rename = "autoUpgrade")]
    auto_upgrade: AutoUpgradeConfig,
}

#[derive(Deserialize, Serialize)]
struct AutoUpgradeConfig {
    enable: bool,
    #[serde(rename = "allowReboot")]
    allow_reboot: bool,
}

fn parse_nixos_config() -> Result<NixosConfig, Box<dyn std::error::Error>> {
    let config_path = "/etc/nixos/configuration.nix";
    let config_content = fs::read_to_string(config_path)?;
    let config: NixosConfig = toml::from_str(&config_content)?;
    Ok(config)
}

// Example 3: Home Directory Backup
fn backup_home_directory() -> Result<(), Box<dyn std::error::Error>> {
    let home_dir = dirs::home_dir().ok_or("Failed to get home directory")?;
    let backup_dir = PathBuf::from("/tmp/home_backup");
    fs::create_dir_all(&backup_dir)?;

    let output = std::process::Command::new("rsync")
        .args(&["-av", "--delete", home_dir.to_str().unwrap(), backup_dir.to_str().unwrap()])
        .output()?;

    if output.status.success() {
        println!("Home directory backup completed successfully");
    } else {
        eprintln!("Backup failed: {}", String::from_utf8_lossy(&output.stderr));
    }

    Ok(())
}

// Example 4: NixOS Package Update Checker
#[derive(Deserialize)]
struct Package {
    name: String,
    version: String,
}

fn check_package_updates() -> Result<(), Box<dyn std::error::Error>> {
    let installed_packages = std::process::Command::new("nix-env")
        .args(&["-q", "--json"])
        .output()?;
    let installed: Vec<Package> = serde_json::from_slice(&installed_packages.stdout)?;

    for package in installed {
        let latest_version = std::process::Command::new("nix-env")
            .args(&["-qa", &format!("^{}$", package.name), "--json"])
            .output()?;
        let latest: Vec<Package> = serde_json::from_slice(&latest_version.stdout)?;

        if let Some(latest) = latest.first() {
            if latest.version != package.version {
                println!("Update available for {}: {} -> {}", package.name, package.version, latest.version);
            }
        }
    }

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("System Information:");
    println!("{}\n", gather_system_info());

    println!("NixOS Configuration:");
    let nixos_config = parse_nixos_config()?;
    println!("State Version: {}", nixos_config.system.state_version);
    println!("Auto Upgrade Enabled: {}", nixos_config.system.auto_upgrade.enable);
    println!("Auto Upgrade Allow Reboot: {}\n", nixos_config.system.auto_upgrade.allow_reboot);

    println!("Backing up home directory...");
    backup_home_directory()?;

    println!("\nChecking for package updates...");
    check_package_updates()?;

    Ok(())
}