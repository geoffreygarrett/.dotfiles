#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! hostname = "0.3"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

#![allow(clippy::single_match)]
use colored::*;
use hostname;
use std::env;
use std::process::Command;

fn get_flake_dir() -> Result<String, String> {
    let mut current_dir = env::current_dir().map_err(|e| e.to_string())?;
    while current_dir.pop() {
        if current_dir.join("flake.nix").exists() {
            return Ok(current_dir.to_string_lossy().into_owned());
        }
    }
    Err("Error: Could not find flake.nix in any parent directory.".into())
}

fn run_command(cmd: &mut Command) -> Result<(), String> {
    let output = cmd.output().map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(format!(
            "Error executing command: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    println!("{}", "Command executed successfully.".green().bold());
    Ok(())
}

fn main() -> Result<(), String> {
    let flake_dir = get_flake_dir()?;
    let username = env::var("USER").unwrap_or_else(|_| "unknown".to_string());
    let hostname = hostname::get()
        .unwrap_or_else(|_| "unknown".into())
        .to_string_lossy()
        .replace(".local", "")
        .to_lowercase();
    let full_config = format!("{}@{}", username, hostname);

    println!(
        "{}",
        format!("Running Home Manager switch for {}...", full_config)
            .blue()
            .bold()
    );

    let mut hm_cmd = Command::new("nix");
    hm_cmd.args(&[
        "run",
        "--quiet",
        &format!(
            "{}#homeConfigurations.{}.activationPackage",
            flake_dir, full_config
        ),
    ]);

    match run_command(&mut hm_cmd) {
        Ok(_) => println!(
            "{}",
            "Home Manager switch executed successfully.".green().bold()
        ),
        Err(e) => {
            eprintln!(
                "{}",
                format!("Error occurred during Home Manager switch: {}", e).red()
            );
            // Try running with --impure flag
            println!("{}", "Attempting to run with --impure flag...".yellow());
            let mut impure_cmd = Command::new("nix");
            impure_cmd.args(&[
                "run",
                "--impure",
                &format!(
                    "{}#homeConfigurations.{}.activationPackage",
                    flake_dir, full_config
                ),
            ]);

            if let Err(e) = run_command(&mut impure_cmd) {
                eprintln!(
                    "{}",
                    format!("Error occurred during impure Home Manager switch: {}", e).red()
                );
                return Err("Home Manager switch failed".into());
            }
        }
    }

    println!("{}", "Restarting shell...".yellow());
    let shell = env::var("SHELL").unwrap_or_else(|_| "/bin/sh".to_string());
    let output = Command::new(shell).output().unwrap_or_else(|e| {
        eprintln!("Failed to exec shell: {}", e);
        std::process::exit(1);
    });

    if !output.status.success() {
        match output.status.code() {
            Some(code) => eprintln!("Shell exited with status code: {}", code),
            None => eprintln!("Shell terminated by signal"),
        }
    }

    Ok(())
}
