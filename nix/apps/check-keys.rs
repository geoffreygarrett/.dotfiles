#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use colored::*;
use std::env;
use std::path::PathBuf;

fn lint_keys(ssh_dir: &PathBuf) {
    let keys = [
        "id_ed25519",
        "id_ed25519.pub",
        "id_ed25519_agenix",
        "id_ed25519_agenix.pub",
    ];

    let mut all_present = true;
    let mut missing_keys = Vec::new();

    for key in &keys {
        if !ssh_dir.join(key).exists() {
            all_present = false;
            missing_keys.push(key);
        }
    }

    if all_present {
        println!("{}", "All SSH keys are present.".green());
    } else {
        println!("{}", "Some SSH keys are missing.".red());
        for key in missing_keys {
            println!("{}", format!("Missing: {}", key).red());
        }
        println!("{}", "Run the create-keys command to generate the missing keys.".green());
        std::process::exit(1);
    }
}

fn main() {
    let username = env::var("USER").expect("Failed to get username");
    let ssh_dir = PathBuf::from(format!("/Users/{}/.ssh", username));

    lint_keys(&ssh_dir);
}