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

fn run_command(mut cmd: Command) -> Result<(), String> {
    let output = cmd.output().map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok(())
}

fn main() -> Result<(), String> {
    // Get system type and flake configuration from environment variables or use defaults
    let system_type = env::var("NIX_SYSTEM_TYPE").unwrap_or_else(|_| String::from("x86_64-linux"));
    let flake_config = env::var("NIX_FLAKE_CONFIG").unwrap_or_else(|_| format!("nixosConfigurations.{}.config", system_type));

    env::set_var("NIXPKGS_ALLOW_UNFREE", "1");

    println!("{}", "Starting build...".yellow());

    let args: Vec<String> = env::args().skip(1).collect();

    // Build command
    let mut build_cmd = Command::new("nix");
    build_cmd.args(&[
        "--extra-experimental-features",
        "nix-command flakes",
        "build",
        &format!(".#{}", flake_config),
    ]);
    build_cmd.args(&args);

    if let Err(e) = run_command(build_cmd) {
        eprintln!("{}", "Build failed!".red());
        eprintln!("{}", e);
        return Err("Build failed".into());
    }

    println!("{}", "Switching to new generation...".yellow());

    // Determine the appropriate rebuild command based on the system type
    let rebuild_cmd = if system_type.contains("darwin") {
        "darwin-rebuild"
    } else {
        "nixos-rebuild"
    };

    // Switch command
    let mut switch_cmd = Command::new(rebuild_cmd);
    switch_cmd.args(&[
        "switch",
        "--flake",
        &format!(".#{}", system_type),
    ]);
    switch_cmd.args(&args);

    if let Err(e) = run_command(switch_cmd) {
        eprintln!("{}", "Switch failed!".red());
        eprintln!("{}", e);
        return Err("Switch failed".into());
    }

    println!("{}", "Cleaning up...".yellow());
    fs::remove_file("./result").map_err(|e| e.to_string())?;

    println!("{}", "Switch to new generation complete!".green());
    Ok(())
}