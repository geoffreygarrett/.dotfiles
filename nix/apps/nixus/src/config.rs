use std::env;
use std::fs;
use std::path::{Path, PathBuf};

// src/config.rs
use colored::*;
use serde::Deserialize;
use snafu::{ResultExt, Snafu};

use crate::config;

#[derive(Debug, Clone, Deserialize)]
pub struct Keys {
    pub ssh: Vec<String>,
    pub wg: Option<Vec<String>>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    pub keys: Keys,
}

#[derive(Debug, Snafu)]
#[allow(dead_code)]
pub enum ConfigError {
    #[snafu(display("Failed to read file at {}: {}", path.display(), source))]
    ReadFile {
        source: std::io::Error,
        path: PathBuf,
    },

    #[snafu(display("Failed to parse TOML content: {}", source))]
    ParseToml { source: toml::de::Error },

    #[snafu(display("No flake configuration found in any of the searched locations"))]
    NoFlakeConfig,

    #[snafu(display("Environment variable not set: {}", name))]
    EnvVarNotSet { name: String },

    #[snafu(display("Failed to get home directory"))]
    NoHomeDir,
}

impl Config {
    pub fn from_file<P: AsRef<Path>>(path: P) -> Result<Self, ConfigError> {
        let path = path.as_ref();
        let content = fs::read_to_string(path).context(ReadFileSnafu { path })?;
        let config: Config = toml::from_str(&content).context(ParseTomlSnafu)?;
        Ok(config)
    }

    pub fn load() -> Result<Self, ConfigError> {
        for location in get_flake_locations()? {
            if location.exists() {
                return Self::from_file(location);
            }
        }
        Err(ConfigError::NoFlakeConfig)
    }
}

pub fn get_flake_locations() -> Result<Vec<PathBuf>, ConfigError> {
    let mut locations = vec![];

    // Check NIXUS_FLAKE environment variable first
    if let Ok(nixus_flake) = env::var("NIXUS_FLAKE") {
        locations.push(PathBuf::from(nixus_flake).join("flake.toml"));
    }

    // Add other default locations
    locations.extend_from_slice(&[
        PathBuf::from("../../flake.toml"),
        PathBuf::from("./flake.toml"),
    ]);

    // Add home directory location
    let home_dir = dirs::home_dir().ok_or(ConfigError::NoHomeDir)?;
    locations.push(home_dir.join(".config/nixus/flake.toml"));

    Ok(locations)
}

pub fn find_flake_dir() -> Result<PathBuf, ConfigError> {
    for location in get_flake_locations()? {
        if location.exists() {
            return Ok(location.parent().unwrap().to_path_buf());
        }
    }
    Err(ConfigError::NoFlakeConfig)
}

#[allow(dead_code)]
pub fn print_flake_info() {
    println!("{}", "Flake Locations:".green().bold());
    match get_flake_locations() {
        Ok(locations) => {
            for (index, location) in locations.iter().enumerate() {
                println!("{}. {}", index + 1, location.display());
            }
        }
        Err(e) => println!("{} {}", "Error getting flake locations:".red().bold(), e),
    }

    match find_flake_dir() {
        Ok(dir) => println!(
            "\n{} {}",
            "Flake directory found at:".green().bold(),
            dir.display()
        ),
        Err(e) => println!("\n{} {}", "Error finding flake directory:".red().bold(), e),
    }
}

pub fn get_flake_dir(flake: Option<PathBuf>) -> Result<PathBuf, String> {
    flake
        .or_else(|| std::env::var("NIXUS_FLAKE").ok().map(PathBuf::from))
        .or_else(|| config::find_flake_dir().ok())
        .ok_or_else(|| "Failed to determine flake directory. Please specify with --flake or set NIXUS_FLAKE environment variable.".to_string())
}

pub fn determine_system_type() -> String {
    let arch = env::consts::ARCH;
    let os = env::consts::OS;

    match (arch, os) {
        ("x86_64", "linux") => "x86_64-linux",
        ("x86_64", "macos") => "x86_64-darwin",
        ("aarch64", "linux") => "aarch64-linux",
        ("aarch64", "macos") => "aarch64-darwin",
        ("aarch64", "android") => "aarch64-android",
        _ => panic!("Unsupported system: {} {}", arch, os),
    }
    .to_string()
}

#[cfg(test)]
mod tests {
    use std::fs::File;
    use std::io::Write;

    use tempfile::tempdir;

    use super::*;

    #[test]
    fn test_config_from_file() {
        let dir = tempdir().unwrap();
        let file_path = dir.path().join("test_config.toml");
        let mut file = File::create(&file_path).unwrap();
        writeln!(
            file,
            r#"
            [keys]
            ssh = ["key1", "key2"]
            wg = ["wg1", "wg2"]
        "#
        )
        .unwrap();

        let config = Config::from_file(file_path).unwrap();
        assert_eq!(config.keys.ssh, vec!["key1", "key2"]);
        assert_eq!(
            config.keys.wg,
            Some(vec!["wg1".to_string(), "wg2".to_string()])
        );
    }

    #[test]
    fn test_get_flake_locations() {
        env::set_var("NIXUS_FLAKE", "/tmp/nixus");
        let locations = get_flake_locations().unwrap();
        assert!(locations.contains(&PathBuf::from("/tmp/nixus/flake.toml")));
        assert!(locations.contains(&PathBuf::from("../../flake.toml")));
        assert!(locations.contains(&PathBuf::from("./flake.toml")));
        env::remove_var("NIXUS_FLAKE");
    }
}
