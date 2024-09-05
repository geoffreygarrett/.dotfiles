#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo
*/

use colored::*;
use std::io::{self, Write};
use std::process::Command;

fn main() -> io::Result<()> {
    const FLAKE: &str = "Dustins-MBP";

    println!("{}", "Available generations:".yellow());

    let output = Command::new("/run/current-system/sw/bin/darwin-rebuild")
        .arg("--list-generations")
        .output()?;

    io::stdout().write_all(&output.stdout)?;

    print!("{}", "Enter the generation number for rollback: ".yellow());
    io::stdout().flush()?;

    let mut gen_num = String::new();
    io::stdin().read_line(&mut gen_num)?;
    let gen_num = gen_num.trim();

    if gen_num.is_empty() {
        println!("{}", "No generation number entered. Aborting rollback.".red());
        return Ok(());
    }

    println!("{}", format!("Rolling back to generation {}...", gen_num).yellow());

    let status = Command::new("/run/current-system/sw/bin/darwin-rebuild")
        .args(&["switch", "--flake", &format!(".#{}", FLAKE), "--switch-generation", gen_num])
        .status()?;

    if status.success() {
        println!("{}", format!("Rollback to generation {} complete!", gen_num).green());
    } else {
        println!("{}", format!("Failed to rollback to generation {}.", gen_num).red());
    }

    Ok(())
}