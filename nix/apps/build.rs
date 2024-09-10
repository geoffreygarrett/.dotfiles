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
use std::fs;
use std::process::Command;

fn main() -> std::io::Result<()> {
    const SYSTEM_TYPE: &str = "aarch64-darwin";
    let flake_system = format!("darwinConfigurations.{}.system", SYSTEM_TYPE);

    // Set environment variable
    env::set_var("NIXPKGS_ALLOW_UNFREE", "1");

    println!("{}", "Starting build...".yellow());

    // Prepare command arguments
    let mut args = vec![
        "--extra-experimental-features".to_string(),
        "nix-command flakes".to_string(),
        "build".to_string(),
        format!(".#{}", flake_system),
    ];

    // Append any additional command-line arguments
    args.extend(env::args().skip(1));

    // Execute nix build command
    let status = Command::new("nix").args(&args).status()?;

    if !status.success() {
        eprintln!("{}", "Build failed!".red());
        return Ok(());
    }

    println!("{}", "Cleaning up...".yellow());

    // Remove the result symlink
    if let Err(e) = fs::remove_file("./result") {
        eprintln!(
            "{}",
            format!("Failed to remove result symlink: {}", e).red()
        );
    }

    println!("{}", "Switch to new generation complete!".green());

    Ok(())
}
