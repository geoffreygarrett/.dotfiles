use std::env;
use std::path::PathBuf;
use std::process::Command;

use clap::Args;
use colored::*;

use crate::config;

#[derive(Args)]
pub struct HomeArgs {
    #[arg(short, long)]
    flake: Option<PathBuf>,

    #[arg(last = true)]
    args: Vec<String>,
}

fn get_full_config() -> String {
    let username = env::var("USER").unwrap_or_else(|_| "unknown".to_string());
    let hostname = hostname::get()
        .map(|h| h.to_string_lossy().replace(".local", "").to_lowercase())
        .unwrap_or_else(|_| "unknown".to_string());
    format!("{}@{}", username, hostname)
}


pub fn run(args: HomeArgs) -> Result<(), String> {
    println!("{}", "Running Home Manager configuration switch...".blue().bold());

    let flake_dir = config::get_flake_dir(args.flake)?;
    let full_config = get_full_config();

    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = Command::new("home-manager")
        .arg("switch")
        .arg("--flake")
        .arg(format!("{}#{}", flake_dir.display(), full_config))
        .args(&args.args)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());
    Ok(())
}

