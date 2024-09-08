use clap::Subcommand;

pub mod darwin;
pub mod android;
pub mod nixos;
pub mod home;

#[derive(Subcommand)]
pub enum Commands {
    Darwin(darwin::Args),
    Android(android::Args),
    NixOS(nixos::Args),
    Home(home::Args),
}