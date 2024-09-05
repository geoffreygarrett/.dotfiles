#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! regex = "1.5"
//! dialoguer = "0.11.0"
//! yubikey = "0.8.0"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use colored::*;
use dialoguer::{Confirm, Input};
use regex::Regex;
use std::env;
use std::fs;
use std::io::{self};
use std::path::Path;
use std::process::{Command, exit};

fn is_darwin() -> bool {
    env::consts::OS == "macos"
}

fn _print(message: &str) {
    println!("{}", message);
}

fn _prompt(message: &str) -> String {
    Input::new().with_prompt(message).interact_text().unwrap()
}

fn ask_for_star() {
    let response = Confirm::new()
        .with_prompt("Would you like to support my work by starring my GitHub repo?")
        .default(true)
        .interact()
        .unwrap();

    if response {
        if is_darwin() {
            Command::new("open").arg("https://github.com/geoffreygarrett/celestial-blueprint").spawn().ok();
        } else {
            Command::new("xdg-open").arg("https://github.com/geoffreygarrett/celestial-blueprint").spawn().ok();
        }
    }
}

fn get_username() -> String {
    let username = env::var("USER").unwrap_or_else(|_| String::from("unknown"));
    if username == "nixos" || username == "root" {
        _prompt("You're running as root. Please enter your desired username:".yellow().to_string().as_str())
    } else {
        username
    }
}

fn get_git_config(key: &str) -> Option<String> {
    Command::new("git")
        .args(&["config", "--get", key])
        .output()
        .ok()
        .and_then(|output| String::from_utf8(output.stdout).ok())
        .map(|s| s.trim().to_string())
}

fn insert_secrets_output() {
    let pattern = r"outputs = \{ self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, agenix \} @inputs:";
    let insert_text = "secrets ";

    let content = fs::read_to_string("flake.nix").expect("Unable to read file");
    let re = Regex::new(pattern).unwrap();
    let new_content = re.replace(&content, |_caps: &regex::Captures| {
        format!("outputs = {{ self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, agenix, {} }} @inputs:", insert_text)
    });

    fs::write("flake.nix", new_content.as_bytes()).expect("Unable to write file");
}

fn insert_secrets_input(github_user: &str, github_secrets_repo: &str) {
    let file_path = "flake.nix";
    let content = fs::read_to_string(file_path).expect("Unable to read file");

    if content.contains(&format!("url = \"git+ssh://git@github.com/{}/{}.git\"", github_user, github_secrets_repo)) {
        println!("The 'secrets' block already exists in the file.");
        return;
    }

    let insert_text = format!(
        "    secrets = {{
      url = \"git+ssh://git@github.com/{}/{}.git\";
      flake = false;
    }};",
        github_user, github_secrets_repo
    );

    let re = Regex::new(r"disko = \{(?s).*?\};").unwrap();
    let new_content = re.replace(&content, |caps: &regex::Captures| {
        format!("{}\n{}", caps.get(0).unwrap().as_str(), insert_text)
    });

    fs::write(file_path, new_content.as_bytes()).expect("Unable to write file");
}

fn select_boot_disk() -> String {
    println!("{}", "Available disks:".yellow());
    let output = Command::new("lsblk")
        .args(&["-nd", "--output", "NAME,SIZE"])
        .output()
        .expect("Failed to execute lsblk");
    let disks = String::from_utf8_lossy(&output.stdout);
    println!("{}", disks);

    println!("{}", "WARNING: All data on the chosen disk will be erased during the installation!".red());
    let boot_disk = _prompt("Please enter the name of your boot disk (e.g., sda, nvme0n1). Do not include the full path (\"/dev/\"):".yellow().to_string().as_str());

    let confirmation = Confirm::new()
        .with_prompt(format!("You have selected {} as the boot disk. This will delete everything on this disk. Are you sure?", boot_disk).yellow().to_string())
        .interact()
        .unwrap();

    if confirmation {
        boot_disk
    } else {
        println!("{}", "Disk selection cancelled by the user. Please run the script again to select the correct disk.".red());
        exit(1);
    }
}

fn confirm_details(username: &str, git_email: &str, git_name: &str, primary_iface: &str, boot_disk: &str, host_name: &str, github_user: &str, github_secrets_repo: &str) {
    println!("{}", format!("Username: {}\nEmail: {}\nName: {}", username, git_email, git_name).green());

    if !is_darwin() {
        println!("{}", format!("Primary interface: {}\nBoot disk: {}\nHostname: {}", primary_iface, boot_disk, host_name).green());
    }

    println!("{}", format!("Secrets repository: {}/{}", github_user, github_secrets_repo).green());

    let confirmation = Confirm::new()
        .with_prompt("Is this correct?")
        .interact()
        .unwrap();

    if !confirmation {
        println!("{}", "Exiting script.".red());
        exit(1);
    }
}

fn replace_tokens(file: &Path, username: &str, git_email: &str, git_name: &str, primary_iface: &str, boot_disk: &str, host_name: &str, github_user: &str, github_secrets_repo: &str) {
    if file.file_name().unwrap() != "apply" {
        let content = fs::read_to_string(file).expect("Unable to read file");
        let new_content = content
            .replace("%USER%", username)
            .replace("%EMAIL%", git_email)
            .replace("%NAME%", git_name)
            .replace("%INTERFACE%", primary_iface)
            .replace("%DISK%", boot_disk)
            .replace("%HOST%", host_name)
            .replace("%GITHUB_USER%", github_user)
            .replace("%GITHUB_SECRETS_REPO%", github_secrets_repo);
        fs::write(file, new_content).expect("Unable to write file");
    }
}

// YubiKey related functions

fn setup_yubikey_sops() -> io::Result<()> {
    println!("{}", "Setting up YubiKey with nix-sops...".green());

    // Check if YubiKey is inserted
    if !Command::new("ykman").arg("list").status()?.success() {
        return Err(io::Error::new(io::ErrorKind::Other, "YubiKey not detected. Please insert your YubiKey and try again."));
    }

    // Generate GPG key on YubiKey
    println!("Generating GPG key on YubiKey...");
    Command::new("gpg")
        .args(&["--card-edit", "--command", "admin", "--command", "generate", "--command", "quit"])
        .status()?;

    // Export public key
    println!("Exporting public key...");
    let output = Command::new("gpg")
        .args(&["--armor", "--export"])
        .output()?;
    let public_key = String::from_utf8_lossy(&output.stdout);

    // Save public key to file
    fs::write("yubikey_pubkey.asc", public_key.as_bytes())?;

    // Configure nix-sops
    println!("Configuring nix-sops...");
    let sops_config = format!(r#"
keys:
  - &yubikey {}
creation_rules:
  - path_regex: secrets/.*
    key_groups:
    - pgp:
      - *yubikey
"#, public_key.trim());

    fs::write(".sops.yaml", sops_config)?;

    println!("{}", "YubiKey and nix-sops setup complete.".green());
    Ok(())
}

fn update_flake_nix() -> io::Result<()> {
    let content = fs::read_to_string("flake.nix")?;
    let updated_content = content
        .replace("inputs = {", "inputs = {\n    sops-nix.url = \"github:mic92/sops-nix\";")
        .replace("outputs = {", "outputs = { sops-nix, ... }:");
    fs::write("flake.nix", updated_content)?;
    Ok(())
}

fn main() -> io::Result<()> {
    ask_for_star();

    let username = get_username();
    let git_email = get_git_config("user.email").unwrap_or_else(|| _prompt("Please enter your email:".yellow().to_string().as_str()));
    let git_name = get_git_config("user.name").unwrap_or_else(|| _prompt("Please enter your name:".yellow().to_string().as_str()));
    let github_user = _prompt("Please enter your Github username:".yellow().to_string().as_str());
    let github_secrets_repo = _prompt("Please enter your Github secrets repository name:".yellow().to_string().as_str());

    let (primary_iface, boot_disk, host_name) = if !is_darwin() {
        let iface = Command::new("ip")
            .args(&["-o", "-4", "route", "show", "to", "default"])
            .output()
            .ok()
            .and_then(|output| String::from_utf8(output.stdout).ok())
            .and_then(|s| s.split_whitespace().nth(4).map(String::from))
            .unwrap_or_else(|| String::from("eth0"));
        println!("{}", format!("Found primary network interface {}", iface).green());

        let disk = select_boot_disk();
        let host = _prompt("Please enter a hostname for the system:".yellow().to_string().as_str());
        (iface, disk, host)
    } else {
        (String::new(), String::new(), String::new())
    };

    confirm_details(&username, &git_email, &git_name, &primary_iface, &boot_disk, &host_name, &github_user, &github_secrets_repo);

    insert_secrets_input(&github_user, &github_secrets_repo);
    insert_secrets_output();

    for entry in fs::read_dir(".")? {
        let entry = entry?;
        let path = entry.path();
        if path.is_file() {
            replace_tokens(&path, &username, &git_email, &git_name, &primary_iface, &boot_disk, &host_name, &github_user, &github_secrets_repo);
        }
    }

    fs::write("/tmp/username.txt", &username)?;
    println!("{}", format!("User {} information applied.", username).green());

    // YubiKey setup (optional)
    let setup_yubikey = Confirm::new()
        .with_prompt("Do you want to set up YubiKey with nix-sops?")
        .default(false)
        .interact()
        .unwrap();

    if setup_yubikey {
        setup_yubikey_sops()?;
        update_flake_nix()?;
        println!("{}", "To encrypt your secrets, run:".yellow());
        println!("sops secrets/example.yaml");
    }

    Ok(())
}