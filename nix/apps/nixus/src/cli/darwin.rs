use std::path::PathBuf;
use std::process::Command;

use clap::{Args, ValueEnum};
use colored::*;

#[derive(Debug, Clone, ValueEnum)]
enum DarwinCommand {
    Switch,
    Build,
}

#[derive(Args)]
pub struct DarwinArgs {
    /// The command to run (switch or build)
    #[arg(value_enum)]
    command: DarwinCommand,

    /// Path to the flake directory
    #[arg(short, long)]
    flake: Option<PathBuf>,

    /// Additional arguments to pass to nix
    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: DarwinArgs) -> Result<(), String> {
    println!("{}", "Running Darwin configuration...".blue().bold());

    let flake_dir = crate::config::get_flake_dir(args.flake)?;
    let system_type = crate::config::determine_system_type();

    match args.command {
        DarwinCommand::Build => build(&flake_dir, &system_type, &args.args),
        DarwinCommand::Switch => {
            build(&flake_dir, &system_type, &args.args)?;
            switch(&flake_dir, &system_type, &args.args)
        }
    }
}

fn build(flake_dir: &PathBuf, system_type: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Building configuration...".yellow());
    let mut command = Command::new("nix");
    command
        .arg("build")
        .arg(format!(".#darwinConfigurations.{}.system", system_type))
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .current_dir(flake_dir);

    if !extra_args.is_empty() {
        command.arg("--");
        command.args(extra_args);
    }

    let build_status = command
        .status()
        .map_err(|e| format!("Failed to execute build command: {}", e))?;

    if !build_status.success() {
        return Err("Build failed".into());
    }

    println!("{}", "Build completed successfully.".green());
    Ok(())
}

fn switch(flake_dir: &PathBuf, system_type: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Switching to new configuration...".yellow());
    let mut command = Command::new("./result/sw/bin/darwin-rebuild");
    command
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .current_dir(flake_dir);

    if !extra_args.is_empty() {
        command.arg("--");
        command.args(extra_args);
    }

    let switch_status = command
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());

    // Cleanup
    let _ = Command::new("unlink")
        .arg("./result")
        .current_dir(flake_dir)
        .status();

    Ok(())
}