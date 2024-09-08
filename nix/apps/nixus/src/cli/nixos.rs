use std::path::PathBuf;
use std::process::Command;

use clap::Args;
use colored::*;

use crate::config;

#[derive(Args)]
pub struct NixOSArgs {
    #[arg(short, long)]
    flake: Option<PathBuf>,

    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: NixOSArgs) -> Result<(), String> {
    println!("{}", "Running NixOS configuration switch...".blue().bold());

    let flake_dir = get_flake_dir(args.flake)?;

    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = Command::new("nixos-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(format!("{}#", flake_dir.display()))
        .args(&args.args)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());
    Ok(())
}

fn get_flake_dir(flake: Option<PathBuf>) -> Result<PathBuf, String> {
    flake
        .or_else(|| std::env::var("NIXUS_FLAKE").ok().map(PathBuf::from))
        .or_else(|| config::find_flake_dir().ok())
        .ok_or_else(|| "Failed to determine flake directory. Please specify with --flake or set NIXUS_FLAKE environment variable.".to_string())
}