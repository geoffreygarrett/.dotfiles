// src/main.rs
use clap::Parser;
use colored::Colorize;

mod cli;
mod config;

#[derive(Parser)]
#[clap(name = "nixus")]
#[clap(about = "A CLI tool for managing Nix configurations")]
struct Cli {
    #[clap(subcommand)]
    command: cli::Commands,
}

fn main() {
    let cli = Cli::parse();
    let result = match cli.command {
        cli::Commands::Darwin(args) => cli::darwin::run(args),
        cli::Commands::Android(args) => cli::android::run(args),
        cli::Commands::NixOS(args) => cli::nixos::run(args),
        cli::Commands::Home(args) => cli::home::run(args),
    };

    if let Err(e) = result {
        eprintln!("{}: {}", "Error".red().bold(), e);
        std::process::exit(1);
    }
}
