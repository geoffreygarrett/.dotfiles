use std::io::{self, BufRead, BufReader, Write};
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::thread;

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

    /// Enable or disable caching (default: true)
    #[arg(long, default_value = "true")]
    cache: bool,

    /// Name of the Cachix cache to use (default: "geoffreygarrett")
    #[arg(long, default_value = "geoffreygarrett")]
    cachix_cache: String,

    /// Additional arguments to pass to nix
    #[arg(last = true)]
    args: Vec<String>,
}

pub fn run(args: DarwinArgs) -> Result<(), String> {
    println!("{}", "Running Darwin configuration...".blue().bold());

    let flake_dir = crate::config::get_flake_dir(args.flake)?;
    let system_type = crate::config::determine_system_type();

    match args.command {
        DarwinCommand::Build => build(
            &flake_dir,
            &system_type,
            args.cache,
            &args.cachix_cache,
            &args.args,
        ),
        DarwinCommand::Switch => {
            build(
                &flake_dir,
                &system_type,
                args.cache,
                &args.cachix_cache,
                &args.args,
            )?;
            switch(
                &flake_dir,
                &system_type,
                args.cache,
                &args.cachix_cache,
                &args.args,
            )
        }
        DarwinCommand::Rollback => rollback(&flake_dir, &system_type, args.cache, &args.args),
    }
}

fn build(
    flake_dir: &PathBuf,
    system_type: &str,
    cache: bool,
    cachix_cache: &str,
    extra_args: &[String],
) -> Result<(), String> {
    println!("{}", "Building configuration...".yellow());

    let mut cmd = CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .arg("build")
        .arg(format!(".#darwinConfigurations.{}.system", system_type))
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .args(extra_args)
        .current_dir(flake_dir);

    if !cache {
        cmd = cmd.arg("--no-link");
    }

    let build_status = cmd
        .status()
        .map_err(|e| format!("Failed to execute build command: {}", e))?;

    if !build_status.success() {
        return Err("Build failed".into());
    }

    println!("{}", "Build completed successfully.".green());

    if !cachix_cache.is_empty() {
        // Get all the paths that were built
        let store_paths = get_build_paths()?;
        push_to_cachix(&cachix_cache, store_paths)?;
    }

    Ok(())
}

fn switch(
    flake_dir: &PathBuf,
    system_type: &str,
    cache: bool,
    cachix_cache: &str,
    extra_args: &[String],
) -> Result<(), String> {
    println!("{}", "Switching to new configuration...".yellow());

    let mut cmd = Command::new("./result/sw/bin/darwin-rebuild");
    cmd.arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .args(extra_args)
        .current_dir(flake_dir)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());

    if !cache {
        cmd.arg("--no-build-nix");
    }

    let mut child = cmd
        .spawn()
        .map_err(|e| format!("Failed to execute switch command: {}", e))?;

    let stdout = child.stdout.take().expect("Failed to capture stdout");
    let stderr = child.stderr.take().expect("Failed to capture stderr");

    let stdout_thread = thread::spawn(move || {
        let mut reader = BufReader::new(stdout);
        let mut line = String::new();
        while reader.read_line(&mut line).unwrap() > 0 {
            print!("\r{}", " ".repeat(79)); // Clear the line
            print!("\r{}", line.trim());
            std::io::stdout().flush().unwrap();
            line.clear();
        }
    });

    let mut error_output = String::new();
    let stderr_thread = thread::spawn(move || {
        let reader = BufReader::new(stderr);
        for line in reader.lines() {
            if let Ok(line) = line {
                error_output.push_str(&line);
                error_output.push('\n');
                eprintln!("{}", line.red());
            }
        }
        error_output
    });

    let status = child
        .wait()
        .map_err(|e| format!("Failed to wait for switch command: {}", e))?;

    stdout_thread.join().expect("Failed to join stdout thread");
    let error_output = stderr_thread.join().expect("Failed to join stderr thread");

    println!(); // Move to the next line after carriage return outputs

    if !status.success() {
        return Err(format!("Switch failed. Error trace:\n{}", error_output));
    }

    println!("{}", "Switch to new configuration complete!".green());

    if !cachix_cache.is_empty() {
        let store_paths = get_build_paths()?;
        push_to_cachix(cachix_cache, store_paths)?;
    }

    // Cleanup
    let _ = Command::new("unlink")
        .arg("./result")
        .current_dir(flake_dir)
        .status();

    Ok(())
}

fn rollback(
    flake_dir: &PathBuf,
    system_type: &str,
    cache: bool,
    extra_args: &[String],
) -> Result<(), String> {
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
    io::stdout()
        .flush()
        .map_err(|e| format!("Failed to flush stdout: {}", e))?;
    let mut gen_num = String::new();
    io::stdin()
        .read_line(&mut gen_num)
        .map_err(|e| format!("Failed to read input: {}", e))?;
    let gen_num = gen_num.trim();

    if gen_num.is_empty() {
        return Err("No generation number entered. Aborting rollback.".into());
    }

    println!(
        "{}",
        format!("Rolling back to generation {}...", gen_num).yellow()
    );

    let mut cmd = CheckedCommand::new("/run/current-system/sw/bin/darwin-rebuild")
        .map_err(|e| format!("Failed to create darwin-rebuild command: {}", e))?
        .arg("switch")
        .arg("--flake")
        .arg(format!(".#{}", system_type))
        .arg("--switch-generation")
        .arg(gen_num)
        .args(extra_args)
        .current_dir(flake_dir);

    if !cache {
        cmd = cmd.arg("--no-build-nix");
    }

    let rollback_status = cmd
        .status()
        .map_err(|e| format!("Failed to execute rollback command: {}", e))?;

    if !rollback_status.success() {
        return Err(format!("Rollback to generation {} failed", gen_num));
    }

    println!(
        "{}",
        format!("Rollback to generation {} complete!", gen_num).green()
    );
    Ok(())
}

fn push_to_cachix(cache_name: &str, store_paths: Vec<String>) -> Result<(), String> {
    println!(
        "{}",
        format!("Pushing store paths to Cachix cache: {}...", cache_name).yellow()
    );
    let mut cmd = CheckedCommand::new("cachix")
        .map_err(|e| format!("Failed to create cachix command: {}", e))?
        .arg("push")
        .arg(cache_name)
        .stdin(std::process::Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to spawn cachix process: {}", e))?;

    let stdin = cmd.stdin.as_mut().ok_or("Failed to open stdin")?;

    for path in store_paths {
        writeln!(stdin, "{}", path)
            .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;
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
