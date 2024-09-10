// // src/cli/mod.rs
// use clap::Subcommand;
//
pub mod android;
pub mod cachix;
pub mod darwin;
pub mod home;
pub mod nixos;
pub mod services;
pub mod ssh_keys;
pub mod styles;
pub mod secrets;
//
// #[derive(Subcommand)]
// pub enum Commands {
//     Darwin(darwin::DarwinArgs),
//     Android(android::AndroidArgs),
//     NixOS(nixos::NixOSArgs),
//     Home(home::HomeArgs),
//     SshKeys(ssh_keys::SshKeysArgs),
//     Cachix(cachix::CachixArgs),
//     Secrets(secrets::SecretsArgs),
// }
