use clap::Parser;
mod cli;

#[derive(Parser)]
#[clap(name = "nixus")]
#[clap(about = "A CLI tool for managing Nix configurations")]
struct Cli {
    #[clap(subcommand)]
    command: cli::Commands,
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        cli::Commands::Darwin(args) => cli::darwin::run(args),
        cli::Commands::Android(args) => cli::android::run(args),
        cli::Commands::NixOS(args) => cli::nixos::run(args),
        cli::Commands::Home(args) => cli::home::run(args),
    }
}