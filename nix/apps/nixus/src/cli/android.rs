use std::path::PathBuf;

use clap::{Args, ValueEnum};
use colored::*;

use crate::utils::CheckedCommand;

#[derive(Debug, Clone, ValueEnum)]
enum AndroidCommand {
    Switch,
    Build,
    Rollback,
}

#[derive(Args)]
pub struct AndroidArgs {
    /// The command to run (switch, build, or rollback)
    #[arg(value_enum)]
    command: AndroidCommand,
    /// Path to the flake directory
    #[arg(short, long)]
    flake: Option<PathBuf>,
    /// Additional arguments to pass to nix-on-droid
    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: AndroidArgs) -> Result<(), String> {
    println!("{}", "Running Android configuration...".blue().bold());
    let flake_dir = crate::config::get_flake_dir(args.flake)?;
    match args.command {
        AndroidCommand::Build => build(&flake_dir, &args.args),
        AndroidCommand::Switch => switch(&flake_dir, &args.args),
        AndroidCommand::Rollback => rollback(&args.args),
    }
}

fn build(flake_dir: &PathBuf, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Building configuration...".yellow());
    let build_status = CheckedCommand::new("nix-on-droid")
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("build")
        .arg("--flake")
        .arg(format!("{}#default", flake_dir.display()))
        .args(extra_args)
        .status()
        .map_err(|e| format!("Failed to execute build command: {}", e))?;

    if !build_status.success() {
        return Err("Build failed".into());
    }
    println!("{}", "Build completed successfully.".green());
    Ok(())
}

fn switch(flake_dir: &PathBuf, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = CheckedCommand::new("nix-on-droid")
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("switch")
        .arg("--flake")
        .arg(format!("{}#default", flake_dir.display()))
        .args(extra_args)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }
    println!("{}", "Switch to new configuration complete!".green());
    Ok(())
}

fn rollback(extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Rolling back to previous configuration...".yellow());
    let rollback_status = CheckedCommand::new("nix-on-droid")
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("rollback")
        .args(extra_args)
        .status()
        .map_err(|e| format!("Failed to execute rollback command: {}", e))?;

    if !rollback_status.success() {
        return Err("Rollback failed".into());
    }
    println!("{}", "Rollback to previous configuration complete!".green());
    Ok(())
}