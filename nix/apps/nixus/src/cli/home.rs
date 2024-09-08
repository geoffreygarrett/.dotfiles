use clap::Args;
use colored::*;
use std::process::Command;
use std::env;

#[derive(Args)]
pub struct Args {
    #[arg(short, long)]
    flake_dir: Option<String>,
}

pub fn run(args: Args) {
    println!("{}", "Running Home Manager configuration switch...".blue().bold());
    let flake_dir = args.flake_dir.unwrap_or_else(|| get_flake_dir().expect("Failed to find flake directory"));
    let username = env::var("USER").unwrap_or_else(|_| "unknown".to_string());
    let hostname = hostname::get().unwrap_or_else(|_| "unknown".into()).to_string_lossy().replace(".local", "").to_lowercase();
    let full_config = format!("{}@{}", username, hostname);

    let mut hm_cmd = Command::new("nix");
    hm_cmd.args(&[
        "run",
        "--quiet",
        &format!("{}#homeConfigurations.{}.activationPackage", flake_dir, full_config),
    ]);

    // Run command and handle errors (simplified for brevity)
    if let Err(e) = run_command(&mut hm_cmd) {
        eprintln!("{}", format!("Error: {}", e).red());
    }
}