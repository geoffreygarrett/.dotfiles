use std::fmt;
use std::io::{self, Write};
use std::str::FromStr;

use clap::{CommandFactory, Parser, Subcommand, ValueEnum};
use clap_complete::{generate, Generator};
use clap_complete_nushell::Nushell;
use colored::*;
use env_logger::Builder;
use log::{debug, error, info, LevelFilter};

mod cli;
mod config;
mod utils;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Clone, Debug)]
struct SopsConfig {
    file: String,
    key_path: String,
    env_var: Option<String>,
}

impl FromStr for SopsConfig {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let parts: Vec<&str> = s.split(',').collect();
        if parts.len() < 2 || parts.len() > 3 {
            return Err("Invalid SOPS config format. Use: file,key_path[,env_var]".to_string());
        }
        Ok(SopsConfig {
            file: parts[0].to_string(),
            key_path: parts[1].to_string(),
            env_var: parts.get(2).map(ToString::to_string),
        })
    }
}

#[derive(Parser)]
#[command(
    name = "nixus", about = "A CLI tool for managing Nix configurations", styles = crate::cli::styles::get_styles()
)]
#[command(version = VERSION)]
struct Cli {
    /// Set the log level
    #[arg(short, long, default_value = "off")]
    log_level: LevelFilter,

    /// SOPS configuration
    #[arg(
        long = "sops",
        number_of_values = 1,
        default_value = "$FLAKE/secrets/default.yaml,cachix-auth-token.value,CACHIX_AUTH_TOKEN"
    )]
    sops_configs: Vec<SopsConfig>,

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
    #[command(name = "nixos")]
    NixOS(cli::nixos::NixOSArgs),
    Home(cli::home::HomeArgs),
    //   SshKeys(cli::ssh_keys::SshKeysArgs),
    Cachix(cli::cachix::CachixArgs),

    Secrets(cli::secrets::SecretsArgs),
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
            Shell::Nushell => format!("mkdir -p ~/.cache/nixus; COMPLETE=nushell {} > ~/.cache/nixus/nixus.nu; echo 'source ~/.cache/nixus/nixus.nu' >> ~/.config/nushell/config.nu", program_name),
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
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

    debug!(
        "Starting Nixus v{} with log level: {:?}",
        VERSION, cli.log_level
    );

    match cli.command {
        Commands::Completions { shell } => {
            info!("Generating completions for {}", shell);
            let mut cmd = Cli::command();
            shell.generate_completion(&mut cmd, "nixus", &mut io::stdout());
        }
        Commands::InstallCompletions { shell } => {
            info!("Generating install command for {} completions", shell);
            let install_command = shell.get_install_command("nixus");
            println!(
                "Run the following command to install completions for {}:",
                shell.to_string().green()
            );
            println!("{}", install_command);
        }
        Commands::Darwin(args) => {
            info!("Running Darwin command");
            cli::darwin::run(args)?;
        }
        Commands::Android(args) => {
            info!("Running Android command");
            cli::android::run(args)?;
        }
        Commands::NixOS(args) => {
            info!("Running NixOS command");
            cli::nixos::run(args)?;
        }
        Commands::Home(args) => {
            info!("Running Home command");
            cli::home::run(args)?;
        }
        // Commands::SshKeys(args) => {
        //     info!("Running SSH keys command");
        //     cli::ssh_keys::run_ssh_keys(args)?;
        // }
        Commands::Cachix(args) => {
            info!("Running Cachix command");
            cli::cachix::run(args)?;
        }
        Commands::Secrets(args) => {
            info!("Running Secrets command");
            cli::secrets::run_secrets(args)?;
        }
    }

    debug!("Nixus completed successfully");
    Ok(())
}
