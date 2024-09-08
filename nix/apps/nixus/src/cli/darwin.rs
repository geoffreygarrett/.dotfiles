use std::path::PathBuf;
use std::process::Command;

use clap::Args;
use colored::*;

#[derive(Args)]
pub struct DarwinArgs {
    #[arg(short, long)]
    flake: Option<PathBuf>,

    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: DarwinArgs) -> Result<(), String> {
    println!("{}", "Running Darwin configuration switch...".blue().bold());

    let flake_dir = crate::config::get_flake_dir(args.flake)?;
    let system_type = crate::config::determine_system_type();

    // Build step
    println!("{}", "Building configuration...".yellow());
    let build_status = Command::new("nix")
        .arg("build")
        .arg(format!(".#darwinConfigurations.{}.system", system_type))
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .args(&args.args)
        .current_dir(&flake_dir)
        .status()
        .map_err(|e| format!("Failed to execute build command: {}", e))?;

    if !build_status.success() {
        return Err("Build failed".into());
    }

    // Switch step
    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = Command::new("./result/sw/bin/darwin-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .args(&args.args)
        .current_dir(&flake_dir)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());

    // Cleanup
    let _ = Command::new("unlink")
        .arg("./result")
        .current_dir(&flake_dir)
        .status();

    Ok(())
}

