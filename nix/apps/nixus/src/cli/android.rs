use std::io::Write;
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

const NIX_ON_DROID: &str = "/data/data/com.termux.nix/files/home/.nix-profile/bin/nix-on-droid";
const CACHIX: &str = "cachix";


#[derive(Args)]
pub struct AndroidArgs {
    /// The command to run (switch, build, or rollback)
    #[arg(value_enum)]
    command: AndroidCommand,

    /// Path to the flake directory
    #[arg(short, long)]
    flake: Option<PathBuf>,

    /// Enable or disable caching (default: true)
    #[arg(long, default_value = "true")]
    cache: bool,

    /// Name of the Cachix cache to use (optional)
    #[arg(long)]
    cachix_cache: Option<String>,

    /// Additional arguments to pass to nix-on-droid
    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: AndroidArgs) -> Result<(), String> {
    println!("{}", "Running Android configuration...".blue().bold());
    let flake_dir = crate::config::get_flake_dir(args.flake)?;
    match args.command {
        AndroidCommand::Build => build(&flake_dir, args.cache, args.cachix_cache.as_deref(), &args.args),
        AndroidCommand::Switch => switch(&flake_dir, args.cache, args.cachix_cache.as_deref(), &args.args),
        AndroidCommand::Rollback => rollback(args.cache, &args.args),
    }
}

fn build(flake_dir: &PathBuf, cache: bool, cachix_cache: Option<&str>, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Building configuration...".yellow());

    let mut cmd = CheckedCommand::new(NIX_ON_DROID)
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("build")
        .arg("--flake")
        .arg(format!("{}#default", flake_dir.display()))
        .args(extra_args);

    if !cache {
        cmd = cmd.arg("--no-link");
    }

    let build_status = cmd.status()
        .map_err(|e| format!("Failed to execute build command: {}", e))?;

    if !build_status.success() {
        return Err("Build failed".into());
    }

    println!("{}", "Build completed successfully.".green());

    if let Some(cache_name) = cachix_cache {
        let store_paths = get_build_paths()?;
        push_to_cachix(cache_name, store_paths)?;
    }

    Ok(())
}

fn switch(flake_dir: &PathBuf, cache: bool, cachix_cache: Option<&str>, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Switching to new configuration...".yellow());

    let mut cmd = CheckedCommand::new(NIX_ON_DROID)
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("switch")
        .arg("--flake")
        .arg(format!("{}#default", flake_dir.display()))
        .args(extra_args);

    if !cache {
        cmd = cmd.arg("--no-build-nix");
    }

    let switch_status = cmd.status()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    if !switch_status.success() {
        return Err("Switch failed".into());
    }

    println!("{}", "Switch to new configuration complete!".green());

    if let Some(cache_name) = cachix_cache {
        let store_paths = get_build_paths()?;
        push_to_cachix(cache_name, store_paths)?;
    }

    Ok(())
}

fn rollback(cache: bool, extra_args: &[String]) -> Result<(), String> {
    println!("{}", "Rolling back to previous configuration...".yellow());

    let mut cmd = CheckedCommand::new(NIX_ON_DROID)
        .map_err(|e| format!("Failed to create nix-on-droid command: {}", e))?
        .arg("rollback")
        .args(extra_args);

    if !cache {
        cmd = cmd.arg("--no-build-nix");
    }

    let rollback_status = cmd.status()
        .map_err(|e| format!("Failed to execute rollback command: {}", e))?;

    if !rollback_status.success() {
        return Err("Rollback failed".into());
    }

    println!("{}", "Rollback to previous configuration complete!".green());
    Ok(())
}

fn push_to_cachix(cache_name: &str, store_paths: Vec<String>) -> Result<(), String> {
    println!("{}", format!("Pushing store paths to Cachix cache: {}...", cache_name).yellow());
    let mut cmd = CheckedCommand::new(CACHIX)
        .map_err(|e| format!("Failed to create cachix command: {}", e))?
        .arg("push")
        .arg(cache_name)
        .stdin(std::process::Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to spawn cachix process: {}", e))?;

    let stdin = cmd.stdin.as_mut().ok_or("Failed to open stdin")?;

    for path in store_paths {
        writeln!(stdin, "{}", path).map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;
    }

    cmd.wait()
        .map_err(|e| format!("Failed to wait for cachix process: {}", e))?;

    Ok(())
}

fn get_build_paths() -> Result<Vec<String>, String> {
    let output = CheckedCommand::new("nix-store")
        .map_err(|e| format!("Failed to create nix-store command: {}", e))?
        .arg("-qR")
        .output()
        .map_err(|e| format!("Failed to execute nix-store command: {}", e))?;

    let paths = String::from_utf8(output.stdout)
        .map_err(|e| format!("Failed to parse nix-store output: {}", e))?
        .lines()
        .map(|line| line.to_string())
        .collect::<Vec<_>>();

    Ok(paths)
}
