use std::fmt;
use std::io::{self, Write};

use clap::{CommandFactory, Parser, Subcommand, ValueEnum};
use clap_complete::{generate, Generator};
use clap_complete_nushell::Nushell;
use colored::*;
use env_logger::Builder;
#[allow(unused_imports)]
use log::{debug, error, info, Level, LevelFilter, warn};

mod cli;
mod config;
mod utils;

#[derive(Parser)]
#[clap(name = "nixus", styles = crate::cli::styles::get_styles())]
#[clap(about = "A CLI tool for managing Nix configurations")]
struct Cli {
    #[arg(short, long, default_value = "off")]
    log_level: LevelFilter,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Generate shell completions
    Completions {
        /// The shell to generate the completions for
        #[arg(value_enum)]
        shell: Shell,
    },
    /// Generate shell completion installation commands
    InstallCompletions {
        /// The shell to generate the installation command for
        #[arg(value_enum)]
        shell: Shell,
    },
    Darwin(cli::darwin::DarwinArgs),
    Android(cli::android::AndroidArgs),
    #[clap(name = "nixos")]
    NixOS(cli::nixos::NixOSArgs),
    Home(cli::home::HomeArgs),
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
enum Shell {
    Bash,
    Elvish,
    Fish,
    PowerShell,
    Zsh,
    Nushell,
}

impl fmt::Display for Shell {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Shell::Bash => write!(f, "Bash"),
            Shell::Elvish => write!(f, "Elvish"),
            Shell::Fish => write!(f, "Fish"),
            Shell::PowerShell => write!(f, "PowerShell"),
            Shell::Zsh => write!(f, "Zsh"),
            Shell::Nushell => write!(f, "Nushell"),
        }
    }
}

impl Shell {
    fn generate_completion(&self, cmd: &mut clap::Command, name: &str, buf: &mut dyn io::Write) {
        match self {
            Shell::Bash => generate(clap_complete::Shell::Bash, cmd, name, buf),
            Shell::Elvish => generate(clap_complete::Shell::Elvish, cmd, name, buf),
            Shell::Fish => generate(clap_complete::Shell::Fish, cmd, name, buf),
            Shell::PowerShell => generate(clap_complete::Shell::PowerShell, cmd, name, buf),
            Shell::Zsh => generate(clap_complete::Shell::Zsh, cmd, name, buf),
            Shell::Nushell => Nushell.generate(cmd, buf),
        }
    }

    fn get_install_command(&self, program_name: &str) -> String {
        match self {
            Shell::Bash => format!("echo \"source <(COMPLETE=bash {})\" >> ~/.bashrc", program_name),
            Shell::Elvish => format!("echo \"eval (COMPLETE=elvish {})\" >> ~/.elvish/rc.elv", program_name),
            Shell::Fish => format!("echo \"source (COMPLETE=fish {} | psub)\" >> ~/.config/fish/config.fish", program_name),
            Shell::PowerShell => format!("echo \"COMPLETE=powershell {} | Invoke-Expression\" >> $PROFILE", program_name),
            Shell::Zsh => format!("echo \"source <(COMPLETE=zsh {})\" >> ~/.zshrc", program_name),
            Shell::Nushell => format!("mkdir ~/.cache/nixus; COMPLETE=nushell {} > ~/.cache/nixus/nixus.nu; echo 'source ~/.cache/nixus/nixus.nu' >> ~/.config/nushell/config.nu", program_name),
        }
    }
}

fn main() {
    let cli = Cli::parse();

    // Initialize the logger with custom formatting
    Builder::new()
        .format(|buf, record| {
            writeln!(
                buf,
                "{}: {}",
                crate::cli::styles::colored_level(record.level()),
                record.args()
            )
        })
        .filter_level(cli.log_level)
        .init();

    debug!("Starting Nixus with log level: {:?}", cli.log_level);

    let result = match cli.command {
        Commands::Completions { shell } => {
            info!("Generating completions for {}", shell);
            let mut cmd = Cli::command();
            shell.generate_completion(&mut cmd, "nixus", &mut io::stdout());
            Ok(())
        }
        Commands::InstallCompletions { shell } => {
            info!("Generating install command for {} completions", shell);
            let install_command = shell.get_install_command("nixus");
            println!("Run the following command to install completions for {}:", shell.to_string().green());
            println!("{}", install_command);
            Ok(())
        }
        Commands::Darwin(args) => {
            info!("Running Darwin command");
            cli::darwin::run(args)
        }
        Commands::Android(args) => {
            info!("Running Android command");
            cli::android::run(args)
        }
        Commands::NixOS(args) => {
            info!("Running NixOS command");
            cli::nixos::run(args)
        }
        Commands::Home(args) => {
            info!("Running Home command");
            cli::home::run(args)
        }
    };

    if let Err(e) = result {
        error!("An error occurred: {}", e);
        eprintln!("{}: {}", "Error".red().bold(), e);
        std::process::exit(1);
    }

    debug!("Nixus completed successfully");
}