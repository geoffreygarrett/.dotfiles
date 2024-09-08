use std::path::PathBuf;
use std::process::Command;

use clap::Args;
use colored::*;

#[derive(Args)]
pub struct AndroidArgs {
    #[arg(short, long)]
    flake: Option<PathBuf>,

    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: AndroidArgs) -> Result<(), String> {
    println!("{}", "Running Android configuration switch...".blue().bold());

    let flake_dir = crate::config::get_flake_dir(args.flake)?;

    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = Command::new("nix-on-droid")
        .arg("switch")
        .arg("--flake")
        .arg(format!("{}#default", flake_dir.display()))
        .args(&args.args)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());
    Ok(())
}
