// src/cli/mod.rs
use clap::Subcommand;

pub mod darwin;
pub mod android;
pub mod nixos;
pub mod home;
pub mod styles;
pub mod ssh_keys;

#[derive(Subcommand)]
pub enum Commands {
    Darwin(darwin::DarwinArgs),
    Android(android::AndroidArgs),
    NixOS(nixos::NixOSArgs),
    Home(home::HomeArgs),
    SshKeys(ssh_keys::SshKeysArgs),
}