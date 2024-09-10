use std::io::Write;
use std::path::PathBuf;

use clap::{Args, ValueEnum};
use colored::*;
use log::{debug, error, info, trace};

use crate::utils::{find_sops_file, get_custom_locations, is_git_repo, CheckedCommand};

#[derive(Debug, Clone, ValueEnum)]
enum CachixCommand {
    Push,
    PushAll,
    PushDeps,
    PushShell,
    WatchStore,
    WatchExec,
    PushFlakeInputs,
    PushFlakeRuntime,
    PushFlakeShell,
}

#[derive(Args)]
pub struct CachixArgs {
    /// The command to run
    #[arg(value_enum)]
    command: CachixCommand,

    /// Name of the Cachix cache
    #[arg(short, long)]
    cache: String,

    /// Path to the directory containing the Nix expressions or Flake
    #[arg(short, long)]
    dir: Option<PathBuf>,

    /// Additional arguments to pass to the underlying commands
    #[arg(last = true)]
    args: Vec<String>,

    /// Path to the SOPS file containing the Cachix token
    #[arg(long)]
    sops_file: Option<PathBuf>,
}

fn setup_cachix_command(
    cmd: CheckedCommand,
    sops_file: &Option<PathBuf>,
) -> Result<CheckedCommand, String> {
    let mut cmd = cmd.with_live_output();
    if let Some(sops_file) = sops_file {
        cmd = cmd.optional_sops_secret_with_name(
            sops_file.to_str().unwrap(),
            "cachix-auth-token.value",
            "CACHIX_AUTH_TOKEN",
        );
    } else {
        let sops_file = find_sops_file()?;
        cmd = cmd.optional_sops_secret_with_name(
            sops_file.to_str().unwrap(),
            "cachix-auth-token.value",
            "CACHIX_AUTH_TOKEN",
        );
    }
    Ok(cmd)
}

fn push(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!("{}", "Pushing runtime dependencies to Cachix...".yellow());

    let output = CheckedCommand::new("nix-build")
        .map_err(|e| format!("Failed to create nix-build command: {}", e))?
        .current_dir(dir)
        .args(extra_args)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix-build: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!("{}", "Push to Cachix completed successfully.".green());
    Ok(())
}

fn push_deps(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!(
        "{}",
        "Pushing build and runtime dependencies to Cachix...".yellow()
    );

    let nix_build = CheckedCommand::new("nix-build")
        .map_err(|e| format!("Failed to create nix-build command: {}", e))?
        .current_dir(dir)
        .args(extra_args)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix-build: {}", e))?;

    let nix_store_qd = CheckedCommand::new("nix-store")
        .map_err(|e| format!("Failed to create nix-store command: {}", e))?
        .arg("-qd")
        .stdin(std::process::Stdio::piped())
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix-store -qd: {}", e))?;

    let nix_store_qr = CheckedCommand::new("nix-store")
        .map_err(|e| format!("Failed to create nix-store command: {}", e))?
        .args(&["-qR", "--include-outputs"])
        .stdin(std::process::Stdio::piped())
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix-store -qR: {}", e))?;

    let grep_output = CheckedCommand::new("grep")
        .map_err(|e| format!("Failed to create grep command: {}", e))?
        .arg("-v")
        .arg("\\.drv$")
        .stdin(std::process::Stdio::piped())
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute grep: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&grep_output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!(
        "{}",
        "Push dependencies to Cachix completed successfully.".green()
    );
    Ok(())
}

fn push_shell(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!("{}", "Pushing shell environment to Cachix...".yellow());

    let output = CheckedCommand::new("nix-build")
        .map_err(|e| format!("Failed to create nix-build command: {}", e))?
        .arg("shell.nix")
        .arg("-A")
        .arg("inputDerivation")
        .current_dir(dir)
        .args(extra_args)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix-build: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!(
        "{}",
        "Push shell environment to Cachix completed successfully.".green()
    );
    Ok(())
}

fn push_all(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!("{}", "Pushing all paths to Cachix...".yellow());

    let output = CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .arg("path-info")
        .arg("--all")
        .current_dir(dir)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix path-info: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .args(extra_args)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!(
        "{}",
        "Push all paths to Cachix completed successfully.".green()
    );
    Ok(())
}

fn watch_store(cache: &str, sops_file: &Option<PathBuf>) -> Result<(), String> {
    println!("{}", "Watching Nix store and pushing to Cachix...".yellow());

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("watch-store")
    .arg(cache)
    .status()
    .map_err(|e| format!("Failed to execute watch-store command: {}", e))
    .and_then(|status| {
        if status.success() {
            println!("{}", "Watch-store completed successfully.".green());
            Ok(())
        } else {
            Err("Watch-store failed".into())
        }
    })
}

fn watch_exec(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    if extra_args.is_empty() {
        return Err("No command specified for watch-exec".into());
    }

    println!("{}", "Watching execution and pushing to Cachix...".yellow());

    let mut cachix_args: Vec<&str> = vec!["watch-exec", cache, "--"];
    cachix_args.extend(extra_args.iter().map(String::as_str));

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .args(&cachix_args)
    .current_dir(dir)
    .status()
    .map_err(|e| format!("Failed to execute watch-exec command: {}", e))
    .and_then(|status| {
        if status.success() {
            println!("{}", "Watch-exec completed successfully.".green());
            Ok(())
        } else {
            Err("Watch-exec failed".into())
        }
    })
}

fn push_flake_inputs(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!("{}", "Pushing flake inputs to Cachix...".yellow());
    let _nix_output = CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .arg("flake")
        .arg("archive")
        .arg("--json")
        .current_dir(dir)
        .args(extra_args)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix flake archive: {}", e))?;

    let jq_output = CheckedCommand::new("jq")
        .map_err(|e| format!("Failed to create jq command: {}", e))?
        .arg("-r")
        .arg(".path,(.inputs|to_entries[].value.path)")
        .stdin(std::process::Stdio::piped())
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute jq: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&jq_output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!(
        "{}",
        "Push flake inputs to Cachix completed successfully.".green()
    );
    Ok(())
}

fn push_flake_runtime(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!("{}", "Pushing flake runtime closure to Cachix...".yellow());

    let nix_output = CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .arg("build")
        .arg("--json")
        .current_dir(dir)
        .args(extra_args)
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute nix build: {}", e))?;

    let jq_output = CheckedCommand::new("jq")
        .map_err(|e| format!("Failed to create jq command: {}", e))?
        .arg("-r")
        .arg(".[].outputs | to_entries[].value")
        .stdin(std::process::Stdio::piped())
        .with_live_output()
        .output()
        .map_err(|e| format!("Failed to execute jq: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .stdin(std::process::Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn cachix process: {}", e))?
    .stdin
    .unwrap()
    .write_all(&jq_output.stdout)
    .map_err(|e| format!("Failed to write to cachix stdin: {}", e))?;

    println!(
        "{}",
        "Push flake runtime closure to Cachix completed successfully.".green()
    );
    Ok(())
}

fn push_flake_shell(
    dir: &PathBuf,
    cache: &str,
    extra_args: &[String],
    sops_file: &Option<PathBuf>,
) -> Result<(), String> {
    println!(
        "{}",
        "Pushing flake shell environment to Cachix...".yellow()
    );

    CheckedCommand::new("nix")
        .map_err(|e| format!("Failed to create nix command: {}", e))?
        .with_live_output()
        .args(&["develop", "--profile", "dev-profile", "-c", "true"])
        .current_dir(dir)
        .args(extra_args)
        .status()
        .map_err(|e| format!("Failed to execute nix develop: {}", e))?;

    setup_cachix_command(
        CheckedCommand::new("cachix")
            .map_err(|e| format!("Failed to create cachix command: {}", e))?,
        sops_file,
    )?
    .arg("push")
    .arg(cache)
    .arg("dev-profile")
    .current_dir(dir)
    .status()
    .map_err(|e| format!("Failed to execute cachix push: {}", e))
    .and_then(|status| {
        if status.success() {
            println!(
                "{}",
                "Push flake shell environment to Cachix completed successfully.".green()
            );
            Ok(())
        } else {
            Err("Push flake shell environment to Cachix failed".into())
        }
    })
}

fn cleanup_dev_profile(dir: &PathBuf) -> Result<(), String> {
    println!("{}", "Cleaning up dev-profile...".yellow());

    CheckedCommand::new("rm")
        .map_err(|e| format!("Failed to create rm command: {}", e))?
        .arg("-rf")
        .arg("dev-profile")
        .current_dir(dir)
        .status()
        .map_err(|e| format!("Failed to remove dev-profile: {}", e))
        .and_then(|status| {
            if status.success() {
                println!("{}", "Dev-profile cleaned up successfully.".green());
                Ok(())
            } else {
                Err("Failed to clean up dev-profile".into())
            }
        })
}

pub fn run(args: CachixArgs) -> Result<(), String> {
    println!("{}", "Running Cachix operation...".blue().bold());

    let dir = args.dir.unwrap_or_else(|| std::env::current_dir().unwrap());

    let result = match args.command {
        CachixCommand::Push => push(&dir, &args.cache, &args.args, &args.sops_file),
        CachixCommand::PushAll => push_all(&dir, &args.cache, &args.args, &args.sops_file),
        CachixCommand::PushDeps => push_deps(&dir, &args.cache, &args.args, &args.sops_file),
        CachixCommand::PushShell => push_shell(&dir, &args.cache, &args.args, &args.sops_file),
        CachixCommand::WatchStore => watch_store(&args.cache, &args.sops_file),
        CachixCommand::WatchExec => watch_exec(&dir, &args.cache, &args.args, &args.sops_file),
        CachixCommand::PushFlakeInputs => {
            push_flake_inputs(&dir, &args.cache, &args.args, &args.sops_file)
        }
        CachixCommand::PushFlakeRuntime => {
            push_flake_runtime(&dir, &args.cache, &args.args, &args.sops_file)
        }
        CachixCommand::PushFlakeShell => {
            let push_result = push_flake_shell(&dir, &args.cache, &args.args, &args.sops_file);
            cleanup_dev_profile(&dir)?;
            push_result
        }
    };

    result.map_err(|e| format!("Cachix operation failed: {}", e))
}

pub fn check_dependencies() -> Result<(), String> {
    let dependencies = vec!["nix", "cachix", "jq"];

    for dep in dependencies {
        if CheckedCommand::new(dep)
            .map_err(|_| format!("{} is not installed or not in PATH", dep))?
            .arg("--version")
            .output()
            .is_err()
        {
            return Err(format!("{} is not installed or not in PATH", dep));
        }
    }

    Ok(())
}
