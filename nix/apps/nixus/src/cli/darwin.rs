// src/cli/darwin.rs
use clap::Args;
use colored::*;
use std::process::Command;
use std::env;
use std::path::PathBuf;

#[derive(Args)]
pub struct Args {
    #[arg(short, long)]
    flake_dir: Option<String>,

    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: Args) {
    println!("{}", "Running Darwin configuration switch...".blue().bold());

    let flake_dir = args.flake_dir
        .map(PathBuf::from)
        .or_else(|| env::var("NIXUS_FLAKE").ok().map(PathBuf::from))
        .unwrap_or_else(|| std::env::current_dir().expect("Failed to get current directory"));

    let system_type = determine_system_type();

    // Build step
    println!("{}", "Building configuration...".yellow());
    let build_status = Command::new("nix")
        .arg("build")
        .arg(format!(".#darwinConfigurations.{}.system", system_type))
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .args(&args.args)
        .current_dir(&flake_dir)
        .status();

    if let Err(e) = build_status {
        eprintln!("{}: {}", "Build failed".red(), e);
        return;
    }

    // Switch step
    println!("{}", "Switching to new configuration...".yellow());
    let switch_status = Command::new("./result/sw/bin/darwin-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .args(&args.args)
        .current_dir(&flake_dir)
        .status();

    match switch_status {
        Ok(status) if status.success() => println!("{}", "Switch to new configuration complete!".green()),
        Ok(_) => eprintln!("{}", "Switch failed".red()),
        Err(e) => eprintln!("{}: {}", "Failed to execute switch command".red(), e),
    }

    // Cleanup
    let _ = Command::new("unlink")
        .arg("./result")
        .current_dir(&flake_dir)
        .status();
}

fn determine_system_type() -> String {
    match env::consts::ARCH {
        "x86_64" => "x86_64-darwin",
        "aarch64" => "aarch64-darwin",
        arch => panic!("Unsupported architecture for Darwin: {}", arch),
    }.to_string()
}

// src/main.rs remains the same

// src/cli/mod.rs remains the same