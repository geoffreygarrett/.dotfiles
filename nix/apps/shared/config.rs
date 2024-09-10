//! ```cargo
//! [dependencies]
//! colored = "2.0"
//! dirs = "5.0"
//! serde = { version = "1.0", features = ["derive"] }
//! toml = "0.5"
//! ```
use serde::Deserialize;
use std::fs;
use std::path::{Path, PathBuf};
use toml;

#[derive(Debug, Clone, Deserialize)]
pub struct Keys {
    pub ssh: Vec<String>,
    pub wg: Option<Vec<String>>,
}
#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    pub keys: Keys,
}

pub static FLAKE_LOCATIONS: &[&str] = &["../../flake.toml", "./flake.toml", "$FLAKE/flake.toml"];

impl Config {
    pub fn from_file<P: AsRef<Path>>(path: P) -> Result<Self, Box<dyn std::error::Error>> {
        let content = fs::read_to_string(path)?;
        let config: Config = toml::from_str(&content)?;
        Ok(config)
    }

    pub fn load() -> Result<Self, Box<dyn std::error::Error>> {
        for location in FLAKE_LOCATIONS.iter() {
            let path = Path::new(location);
            if path.exists() {
                return Self::from_file(path);
            }
        }
        Err("No flake configuration found".into())
    }
}

pub fn get_flake_locations() -> Vec<PathBuf> {
    FLAKE_LOCATIONS
        .iter()
        .map(|&loc| {
            if loc.starts_with("$") {
                let (env_var, path) = loc.split_at(loc.find('/').unwrap_or(loc.len()));
                if let Ok(env_value) = std::env::var(&env_var[1..]) {
                    PathBuf::from(env_value).join(path.trim_start_matches('/'))
                } else {
                    PathBuf::from(loc)
                }
            } else {
                PathBuf::from(loc)
            }
        })
        .collect()
}
