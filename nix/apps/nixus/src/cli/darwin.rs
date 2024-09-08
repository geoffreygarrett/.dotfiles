use std::io::{self, Write};
use std::path::PathBuf;

use clap::{Args, ValueEnum};
use colored::*;

use crate::utils::CheckedCommand;

#[derive(Debug, Clone, ValueEnum)]
enum DarwinCommand {
    Switch,
    Build,
    Rollback,
}

#[derive(Args)]
pub struct DarwinArgs {
    /// The command to run (switch, build, or rollback)
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
        DarwinCommand::Rollback => rollback(&flake_dir, &system_type, &args.args)
    }
}

fn forward_command(flake_dir: &PathBuf, command: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", format!("Forwarding '{}' command to darwin-rebuild...", command).yellow());

    CheckedCommand::new("/run/current-system/sw/bin/darwin-rebuild")
        .map_err(|e| format!("Failed to create darwin-rebuild command: {}", e))?
        .arg(command)  // Use the forwarded command
        .args(extra_args)
        .current_dir(flake_dir)
        .status()
        .map_err(|e| format!("Failed to forward command: {}", e))
        .and_then(|status| {
            if status.success() {
                println!("{}", "Command forwarded successfully.".green());
                Ok(())
            } else {
                Err("Forwarded command failed".into())
            }
        })
}

fn build(flake_dir: &PathBuf, system_type: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Building configuration...".yellow());
    CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .arg("build")
        .arg(format!(".#darwinConfigurations.{}.system", system_type))
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .args(extra_args)
        .current_dir(flake_dir)
        .status()
        .map_err(|e| format!("Failed to execute build command: {}", e))
        .and_then(|status| {
            if status.success() {
                println!("{}", "Build completed successfully.".green());
                Ok(())
            } else {
                Err("Build failed".into())
            }
        })
}

fn switch(flake_dir: &PathBuf, system_type: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Switching to new configuration...".yellow());
    CheckedCommand::new("./result/sw/bin/darwin-rebuild")
        .map_err(|e| format!("Failed to create darwin-rebuild command: {}", e))?
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .args(extra_args)
        .current_dir(flake_dir)
        .status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))
        .and_then(|status| {
            if status.success() {
                println!("{}", "Switch to new configuration complete!".green());
                // Cleanup
                let _ = CheckedCommand::new("unlink")
                    .map_err(|e| format!("Failed to create unlink command: {}", e))?
                    .arg("./result")
                    .current_dir(flake_dir)
                    .status();
                Ok(())
            } else {
                Err("Switch failed".into())
            }
        })
}

fn rollback(flake_dir: &PathBuf, system_type: &str, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Preparing for rollback...".yellow());

    // List available generations
    println!("{}", "Available generations:".yellow());
    CheckedCommand::new("/run/current-system/sw/bin/darwin-rebuild")
        .map_err(|e| format!("Failed to create darwin-rebuild command: {}", e))?
        .arg("--list-generations")
        .status()
        .map_err(|e| format!("Failed to list generations: {}", e))?;

    // Get user input for generation number
    print!("{}", "Enter the generation number for rollback: ".yellow());
    io::stdout().flush().map_err(|e| format!("Failed to flush stdout: {}", e))?;
    let mut gen_num = String::new();
    io::stdin().read_line(&mut gen_num).map_err(|e| format!("Failed to read input: {}", e))?;
    let gen_num = gen_num.trim();

    if gen_num.is_empty() {
        return Err("No generation number entered. Aborting rollback.".into());
    }

    println!("{}", format!("Rolling back to generation {}...", gen_num).yellow());

    CheckedCommand::new("/run/current-system/sw/bin/darwin-rebuild")
        .map_err(|e| format!("Failed to create darwin-rebuild command: {}", e))?
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .arg("--switch-generation")
        .arg(gen_num)
        .args(extra_args)
        .current_dir(flake_dir)
        .status()
        .map_err(|e| format!("Failed to execute rollback command: {}", e))
        .and_then(|status| {
            if status.success() {
                println!("{}", format!("Rollback to generation {} complete!", gen_num).green());
                Ok(())
            } else {
                Err(format!("Rollback to generation {} failed", gen_num))
            }
        })
}