#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dialoguer = "0.11.0"
//! serde = { version = "1.0.209", features = ["derive"] }
//! dirs = "5.0"
//! which = "6.0.3"
//! serde_yaml = "0.9.34"
//! toml = "0.5"
//! hostname = "0.4.0"
//! serde_json = "1.0.69"
//! local-ip-address = "=0.3.0"
//! ```
use std::collections::HashMap;
use std::fs;
use std::io::{self, Write};
use std::net::IpAddr;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use colored::*;
use dialoguer::Confirm;
use dirs::home_dir;
use local_ip_address::local_ip;
use serde::{Deserialize, Serialize};
use which::which;

#[path = "shared/config.rs"]
#[allow(dead_code)]
mod shared;

// Structure representing the Interface section in WireGuard config
#[derive(Debug, Serialize, Deserialize)]
struct Interface {
    #[serde(rename = "PrivateKey")]
    private_key: String,

    #[serde(rename = "Address")]
    address: String,

    #[serde(rename = "DNS")]
    dns: String,
}

// Structure representing the Peer section in WireGuard config
#[derive(Debug, Serialize, Deserialize)]
struct Peer {
    #[serde(rename = "PublicKey")]
    public_key: String,

    #[serde(rename = "Endpoint")]
    endpoint: String,

    #[serde(rename = "AllowedIPs")]
    allowed_ips: String,

    #[serde(rename = "PersistentKeepalive")]
    persistent_keepalive: u32,
}

#[derive(Debug, Serialize, Deserialize)]
struct WireGuardTomlConfig {
    #[serde(rename = "Interface")]
    interface: Interface,

    #[serde(rename = "Peer", skip_serializing_if = "Vec::is_empty")]
    peers: Vec<Peer>, // Multiple peers as an array
}

// Structure representing a device (used for storing device info)
#[derive(Debug, Serialize, Deserialize)]
struct Device {
    name: String,        // Name of the device (hostname)
    public_key: String,  // Public key for WireGuard
    allowed_ips: String, // Allowed IPs for the device (used in WireGuard)
    endpoint: String,    // Device's public or local IP with port
}

// Overall configuration holding all devices (optional for future extension)
#[derive(Debug, Serialize, Deserialize, Default)]
struct WireguardConfig {
    #[serde(flatten)]
    devices: HashMap<String, Device>,
}

// Function to find the secrets file relative to the flake locations
fn get_secrets_path() -> Option<PathBuf> {
    for flake_location in shared::get_flake_locations() {
        let secrets_path = flake_location
            .parent()
            .unwrap()
            .join("nix/home/geoffrey/global/secrets.yaml");
        if secrets_path.exists() {
            return Some(secrets_path);
        }
    }
    None
}

// Function to check if `sops` is available
fn check_sops_installed() -> io::Result<()> {
    if which("sops").is_err() {
        eprintln!(
            "{} {} {}",
            "Error:".bold().red(),
            "sops".bold().yellow(),
            "not found. Please install `sops` to proceed.".red()
        );
        Err(io::Error::new(
            io::ErrorKind::NotFound,
            "`sops` command not found. Please install it.",
        ))
    } else {
        Ok(())
    }
}

fn prompt_overwrite(file_path: &Path) -> io::Result<bool> {
    if file_path.exists() {
        println!(
            "{} {} exists.",
            "Notice:".bold().yellow(),
            file_path.display()
        );
        let overwrite = Confirm::new()
            .with_prompt("Do you want to overwrite the existing key?")
            .default(false)
            .interact()
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e.to_string()))?;
        Ok(overwrite)
    } else {
        Ok(true)
    }
}

fn sanitize_hostname(hostname: &str) -> String {
    let lowercased = hostname.to_lowercase();
    let suffix = ".local";

    if lowercased.ends_with(suffix) {
        lowercased.trim_end_matches(suffix).to_string()
    } else {
        lowercased
    }
}

// Function to add a new device to the SOPS file using the correct JSON format for `sops set`
fn sops_set(config_path: &Path, hostname: &str, device: &Device) -> io::Result<()> {
    let device_json = serde_json::to_string(device).unwrap();
    let sanitized_hostname = sanitize_hostname(hostname);
    let key_path = format!(r#"["wireguard"]["{}"]"#, sanitized_hostname);
    let output = Command::new("sops")
        .arg("--set")
        .arg(format!(r#"{} {}"#, key_path, device_json))
        .arg(config_path)
        .output()?;
    if !output.status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            format!(
                "Failed to set value in SOPS file: {}",
                String::from_utf8_lossy(&output.stderr)
            ),
        ));
    }
    Ok(())
}

// Generate private key and public key dynamically
fn generate_private_key() -> io::Result<String> {
    let output = Command::new("wg").arg("genkey").output()?;

    if !output.status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            format!(
                "Failed to generate private key: {}",
                String::from_utf8_lossy(&output.stderr)
            ),
        ));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

// Generate public key from the private key dynamically
fn generate_public_key(private_key: &str) -> io::Result<String> {
    let mut child = Command::new("wg")
        .arg("pubkey")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    if let Some(stdin) = child.stdin.as_mut() {
        stdin.write_all(private_key.as_bytes())?;
    }

    let output = child.wait_with_output()?;

    if !output.status.success() {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            format!(
                "Failed to generate public key: {}",
                String::from_utf8_lossy(&output.stderr)
            ),
        ));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn write_wireguard_conf(
    device: &Device,
    peers: HashMap<String, &Device>,
    private_key: &str,
    dns: &str,
    wg_conf_path: &Path,
    persist_keepalive: u32,
) -> io::Result<()> {
    // IP of this device (device itself) as /24
    let device_ip = format!("{}/24", device.allowed_ips);

    // Collect peer configurations
    let peer_configs: Vec<Peer> = peers
        .iter()
        .map(|(_, peer_device)| Peer {
            public_key: peer_device.public_key.clone(),
            endpoint: peer_device.endpoint.clone(),
            allowed_ips: format!("{}/32", peer_device.allowed_ips),
            persistent_keepalive: persist_keepalive,
        })
        .collect();

    // WireGuard TOML configuration structure
    let wg_conf = WireGuardTomlConfig {
        interface: Interface {
            private_key: private_key.to_string(),
            address: device_ip,
            dns: dns.to_string(),
        },
        peers: peer_configs, // Store all peers here as an array
    };

    // Serialize to TOML and write to the config file
    let toml_content = toml::to_string(&wg_conf).unwrap();
    fs::write(wg_conf_path, toml_content)?;
    println!(
        "  {}: WireGuard config written to {}",
        "Success".green(),
        wg_conf_path.display()
    );
    Ok(())
}

fn sync_wireguard_keys(config_path: &PathBuf) -> Result<(), Box<dyn std::error::Error>> {
    let private_key = generate_private_key()?;
    let public_key = generate_public_key(&private_key)?;
    let mut hostname = hostname::get()?
        .to_str()
        .unwrap_or("unknown-host")
        .to_string();
    hostname = sanitize_hostname(&hostname);
    let new_device = Device {
        name: hostname.clone(),
        public_key: public_key.clone(), // Store only the public key
        allowed_ips: "0.0.0.0/0".to_string(),
        endpoint: format!(
            "{}:51820",
            local_ip().unwrap_or(IpAddr::V4([0, 0, 0, 0].into()))
        ),
    };

    // Check if the device already exists in the SOPS file, otherwise use `sops set` to add it
    println!("Adding new device: {}", new_device.name.bold().cyan());

    // Use `sops set` to update the device under wireguard.[hostname]
    sops_set(config_path, &hostname, &new_device)?;

    // Syncing the keys for each device
    let wg_dir = home_dir().unwrap().join(".wireguard");
    let private_key_path = wg_dir.join(format!("{}_private.key", new_device.name));
    let public_key_path = wg_dir.join(format!("{}_public.key", new_device.name));

    // Store the private key locally
    if prompt_overwrite(&private_key_path)? {
        fs::write(&private_key_path, &private_key)?;
        println!(
            "  {}: {}",
            "Private key synced locally".green(),
            private_key_path.display()
        );
    } else {
        println!("  {}: Skipped private key", "Skipped".yellow());
    }

    // Store the public key locally
    fs::write(&public_key_path, &public_key)?;
    println!(
        "  {}: {}",
        "Public key synced locally".green(),
        public_key_path.display()
    );

    // Write WireGuard TOML configuration
    let wg_conf_path = wg_dir.join(format!("wg0_{}.conf", new_device.name));

    // Fix: Store the result of extract_wireguard_config in a binding
    let wireguard_config = extract_wireguard_config(config_path)?;
    let peers: HashMap<String, &Device> = wireguard_config
        .devices
        .iter()
        .filter(|(name, _)| **name != new_device.name) // Exclude the new device by name
        .map(|(name, device)| (name.clone(), device)) // Convert &String to String
        .collect();

    let dns = "10.0.0.1";
    write_wireguard_conf(&new_device, peers, &private_key, dns, &wg_conf_path, 25)?;

    Ok(())
}

// Function to extract the wireguard configuration from SOPS file
fn extract_wireguard_config(
    config_path: &Path,
) -> Result<WireguardConfig, Box<dyn std::error::Error>> {
    let output = Command::new("sops")
        .arg("--decrypt")
        .arg("--extract")
        .arg(r#"["wireguard"]"#)
        .arg(config_path)
        .output()?;

    if !output.status.success() {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!(
                "Failed to extract WireGuard config: {}",
                String::from_utf8_lossy(&output.stderr)
            ),
        )));
    }

    let config_str = String::from_utf8_lossy(&output.stdout);
    let wireguard_config: WireguardConfig = serde_yaml::from_str(&config_str)?;

    Ok(wireguard_config)
}

fn main() -> io::Result<()> {
    // Ensure `sops` is installed before proceeding
    check_sops_installed()?;

    // Find the secrets path using flake location logic
    if let Some(config_path) = get_secrets_path() {
        println!("{}", "=== WireGuard Sync ===".bold().blue());

        if let Err(e) = sync_wireguard_keys(&config_path) {
            eprintln!("{}", format!("Error: {}", e).red());
        }

        println!("{}", "=== WireGuard Sync Complete ===".bold().green());
    } else {
        eprintln!("{}", "No WireGuard configuration found.".red());
    }

    Ok(())
}
