#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! aes-gcm = "0.10.1"
//! chacha20poly1305 = "0.10.1"
//! rand = "0.8.5"
//! sha2 = "0.10.6"
//! zeroize = "1.6.0"
//! colored = "2.0.0"
//! serde = { version = "1.0", features = ["derive"] }
//! serde_json = "1.0"
//! toml = "0.7.3"
//! regex = "1.5"
//! rpassword = "7.2"
//! snafu = "0.7"
//! ```

#[path = "shared/usb.rs"]
#[allow(dead_code)]
mod shared_usb;

use aes_gcm::aead::{Aead, KeyInit};
use chacha20poly1305::ChaCha20Poly1305;
use colored::*;
use rand::{rngs::OsRng, RngCore};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use shared_usb::{get_password, select_usb_device};
use snafu::prelude::*;
use std::fs::{File, OpenOptions};
use std::io::{self, Read, Write};
use std::path::Path;
use std::process::Command;
use zeroize::Zeroize;

const MAX_ATTEMPTS: u8 = 5;
const NONCE_SIZE: usize = 12;
const KEY_SIZE: usize = 32;

#[derive(Serialize, Deserialize)]
struct Config {
    encrypted_data: Vec<u8>,
    salt: [u8; 32],
    nonce: [u8; NONCE_SIZE],
    attempts: u8,
}

#[derive(Debug, Snafu)]
enum Error {
    #[snafu(display("I/O error: {source}"))]
    Io { source: std::io::Error },

    #[snafu(display("USB error: {source}"))]
    Usb { source: shared_usb::Error },

    #[snafu(display("Encryption error"))]
    Encryption,

    #[snafu(display("Decryption error"))]
    Decryption,

    #[snafu(display("Serialization error: {source}"))]
    Serialization { source: toml::ser::Error },

    #[snafu(display("Deserialization error: {source}"))]
    Deserialization { source: toml::de::Error },

    #[snafu(display("Read-only filesystem"))]
    ReadOnlyFilesystem,

    #[snafu(display("Too many incorrect attempts"))]
    TooManyAttempts,

    #[snafu(display("Device not found"))]
    DeviceNotFound,

    #[snafu(display("Device name not found"))]
    DeviceNameParseFailed,

    #[snafu(display("Unsupported operating system"))]
    UnsupportedOS,
}
impl From<std::io::Error> for Error {
    fn from(source: std::io::Error) -> Self {
        Error::Io { source }
    }
}
type Result<T, E = Error> = std::result::Result<T, E>;

fn main() -> Result<()> {
    println!("{}", "=== USB Master Key Generator ===".bold().blue());

    // Select USB device and potentially a partition
    let (usb_device, maybe_partition) = select_usb_device().context(UsbSnafu)?;

    // Determine the base path from either the partition or the disk itself
    let base_path = match maybe_partition {
        Some(ref partition) => partition
            .mountpoint
            .clone()
            .unwrap_or(usb_device.name.clone()), // Use partition mountpoint if available
        None => usb_device.name.clone(), // Fallback to the disk name if no partition is selected
    };

    // Create the full path to the config file
    let config_path = Path::new(&base_path).join("master_key.toml");

    loop {
        match run_key_operation(&config_path) {
            Ok(_) => break,
            Err(Error::ReadOnlyFilesystem) => {
                // Pass maybe_partition instead of is_partition
                if !handle_readonly_filesystem(&usb_device, maybe_partition.as_ref())? {
                    return Ok(());
                }
            }
            Err(e) => return Err(e),
        }
    }

    Ok(())
}

fn run_key_operation(config_path: &Path) -> Result<()> {
    if config_path.exists() {
        decrypt_and_use_key(config_path)
    } else {
        generate_and_encrypt_key(config_path)
    }
}

fn handle_readonly_filesystem(
    device: &shared_usb::Disk,
    maybe_partition: Option<&shared_usb::Partition>,
) -> Result<bool> {
    println!(
        "\n{}",
        "The USB drive is mounted as read-only.".red().bold()
    );
    println!("{}\n", "Please choose an option:".bold());

    println!(
        "1. {}",
        "Attempt to remount the USB drive with write permissions".cyan()
    );
    println!("2. {}", "Format the USB drive".cyan());
    println!(
        "   {}",
        "WARNING: This will erase all data on the drive".red()
    );
    println!("3. {}", "Exit the program".cyan());

    loop {
        print!("\n{}", "Enter your choice (1-3): ".green());
        io::stdout().flush().context(IoSnafu)?;

        let mut choice = String::new();
        io::stdin().read_line(&mut choice).context(IoSnafu)?;

        match choice.trim() {
            "1" => {
                // Remount the partition if available, or the disk if not
                let device_to_remount =
                    maybe_partition.map_or_else(|| &device.name, |partition| &partition.name);
                provide_remount_instructions(device_to_remount);
                return Ok(true);
            }
            "2" => {
                // Format the partition if available, or the disk if not
                let is_partition = maybe_partition.is_some();
                let device_name =
                    maybe_partition.map_or_else(|| &device.name, |partition| &partition.name);
                provide_format_instructions(device_name, is_partition);
                return Ok(true);
            }
            "3" => return Ok(false),
            _ => println!("{}", "Invalid choice. Please try again.".yellow()),
        }
    }
}

fn provide_format_instructions(device_name: &str, is_partition: bool) {
    println!(
        "\n{}",
        "WARNING: Formatting will erase all data on the USB drive."
            .red()
            .bold()
    );
    println!(
        "{}\n",
        "To format the USB drive, follow these steps:".bold()
    );

    if is_partition {
        // Commands for formatting a partition
        println!("1. Verify the detected partition: {}", device_name.yellow());
        println!("\n2. Format the partition:");
        println!("   {}", format!("sudo umount {}", device_name).yellow());
        println!(
            "   {}",
            format!("sudo mkfs.vfat -F 32 {}", device_name).yellow()
        );
        println!("   {}", "sudo mkdir -p /media/usbdrive".yellow());
        println!(
            "   {}",
            format!("sudo mount {} /media/usbdrive", device_name).yellow()
        );
    } else {
        // Commands for formatting the entire disk
        println!("1. Verify the detected USB drive: {}", device_name.yellow());
        println!("\n2. Format the drive:");
        println!("   {}", format!("sudo umount {}*", device_name).yellow());
        println!(
            "   {}",
            format!("sudo parted {} mklabel msdos", device_name).yellow()
        );
        println!(
            "   {}",
            format!("sudo parted {} mkpart primary fat32 1 100%", device_name).yellow()
        );
        println!(
            "   {}",
            format!("sudo mkfs.vfat -F 32 {}1", device_name).yellow()
        );
        println!("   {}", "sudo mkdir -p /media/usbdrive".yellow());
        println!(
            "   {}",
            format!("sudo mount {}1 /media/usbdrive", device_name).yellow()
        );
    }

    println!(
        "\n   {}",
        "IMPORTANT: Verify that the device is correct before running these commands.".red()
    );
    println!(
        "   {}",
        "These commands will erase all data on the device and create a new partition.".red()
    );

    println!(
        "\nAfter formatting, press {} to continue or type {} to quit.",
        "Enter".green(),
        "'exit'".red()
    );

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or_default();
    if input.trim().to_lowercase() == "exit" {
        std::process::exit(0);
    }
}

fn provide_remount_instructions(device_name: &str) {
    println!(
        "\n{}",
        "To remount the USB drive with write permissions, follow these steps:".bold()
    );

    if cfg!(target_os = "linux") {
        println!("\n1. {}", "Open a terminal.".cyan());
        println!(
            "2. {}",
            "Run the following command to remount as read-write:".cyan()
        );
        println!(
            "   {}",
            format!("sudo mount -o remount,rw {}", device_name).yellow()
        );
    } else if cfg!(target_os = "macos") {
        println!("\n1. {}", "Open a terminal.".cyan());
        println!(
            "2. {}",
            "Run the following command to remount as read-write:".cyan()
        );
        println!(
            "   {}",
            format!("diskutil mountWithOptions readWrite {}", device_name).yellow()
        );
    }

    println!("\nAfter remounting, press Enter to continue or type 'exit' to quit.");
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or_default();
    if input.trim().to_lowercase() == "exit" {
        std::process::exit(0);
    }
}

fn get_device_info(mount_point: &Path) -> Result<(String, String)> {
    if cfg!(target_os = "linux") {
        get_device_info_linux(mount_point)
    } else if cfg!(target_os = "macos") {
        get_device_info_macos(mount_point)
    } else {
        Err(Error::UnsupportedOS)
    }
}

fn get_device_info_linux(mount_point: &Path) -> Result<(String, String)> {
    let output = Command::new("lsblk")
        .arg("-npo")
        .arg("NAME,MOUNTPOINT")
        .output()
        .context(IoSnafu)?;

    let output_str = String::from_utf8_lossy(&output.stdout);
    let mut device = None;
    let mut partition = None;

    for line in output_str.lines() {
        let parts: Vec<&str> = line.split_whitespace().collect();
        if parts.len() == 2 && parts[1] == mount_point.to_str().unwrap() {
            partition = Some(parts[0].to_string());

            // Extract the base device path correctly
            let device_candidate = partition.as_ref().unwrap();
            let base_device = device_candidate.trim_end_matches(char::is_numeric);
            device = Some(format!("/dev/{}", base_device));
        }
    }

    if let (Some(dev), Some(part)) = (device, partition) {
        Ok((dev, part))
    } else {
        Err(Error::DeviceNotFound)
    }
}
fn get_device_info_macos(mount_point: &Path) -> Result<(String, String)> {
    // let output = std::process::Command::new("diskutil")
    //     .args(&["info", "-plist", mount_point.to_str().ok_or(Error::DeviceNameParseFailed)?])
    //     .output()
    //     .context(IoSnafu)?;
    //
    // let plist = String::from_utf8_lossy(&output.stdout);
    // let dev_entry = plist.lines()
    //     .find(|line| line.contains("<key>DeviceIdentifier</key>"))
    //     .ok_or(Error::DeviceNotFound)?;
    //
    // let dev_name = plist.lines()
    //     .nth(plist.lines().position(|line| line == dev_entry).ok_or(Error::DeviceNotFound)? + 1)
    //     .ok_or(Error::DeviceNotFound)?;
    //
    // let cleaned_dev_name = dev_name.trim().trim_matches(|c| c == '<' || c == '>' || c == '/' || c == 's' || c == 't' || c == 'r' || c == 'i' || c == 'n' || c == 'g');
    //
    // if cleaned_dev_name.is_empty() {
    Err(Error::DeviceNotFound)
    // } else {
    //     Ok(format!("/dev/{}", cleaned_dev_name))
    // }
}

fn generate_and_encrypt_key(config_path: &Path) -> Result<()> {
    if !is_filesystem_writable(config_path) {
        return Err(Error::ReadOnlyFilesystem);
    }

    let mut key = [0u8; KEY_SIZE];
    OsRng.fill_bytes(&mut key);

    let password =
        get_password("Enter a password to encrypt the master key: ").context(UsbSnafu)?;
    let salt = generate_salt();
    let derived_key = derive_key(&password, &salt);

    let mut nonce = [0u8; NONCE_SIZE];
    OsRng.fill_bytes(&mut nonce);

    let cipher = ChaCha20Poly1305::new(derived_key.as_ref().into());
    let encrypted_data = cipher
        .encrypt(nonce.as_ref().into(), key.as_ref())
        .map_err(|_| Error::Encryption)?;

    let config = Config {
        encrypted_data,
        salt,
        nonce,
        attempts: 0,
    };

    save_config(config_path, &config)?;
    println!(
        "{}",
        "Master key generated and encrypted successfully.".green()
    );
    key.zeroize();

    Ok(())
}

fn decrypt_and_use_key(config_path: &Path) -> Result<()> {
    if !is_filesystem_writable(config_path) {
        return Err(Error::ReadOnlyFilesystem);
    }

    let mut config = load_config(config_path)?;

    if config.attempts >= MAX_ATTEMPTS {
        eprintln!(
            "{}",
            "Too many incorrect attempts. USB data will be wiped.".red()
        );
        return Err(Error::TooManyAttempts);
    }

    let password =
        get_password("Enter the password to decrypt the master key: ").context(UsbSnafu)?;
    let derived_key = derive_key(&password, &config.salt);

    let cipher = ChaCha20Poly1305::new(derived_key.as_ref().into());
    let decrypted_key = cipher
        .decrypt(config.nonce.as_ref().into(), config.encrypted_data.as_ref())
        .map_err(|_| Error::Decryption)?;

    println!("{}", "Master key decrypted successfully.".green());
    println!("Decrypted key: {:?}", decrypted_key);

    config.attempts = 0;
    save_config(config_path, &config)?;

    Ok(())
}

fn is_filesystem_writable(path: &Path) -> bool {
    if path.exists() {
        std::fs::metadata(path)
            .map(|metadata| !metadata.permissions().readonly())
            .unwrap_or(false)
    } else if let Some(parent) = path.parent() {
        let temp_file_path = parent.join(".write_test_temp");
        std::fs::File::create(&temp_file_path)
            .and_then(|_| std::fs::remove_file(&temp_file_path))
            .is_ok()
    } else {
        false
    }
}

fn generate_salt() -> [u8; 32] {
    let mut salt = [0u8; 32];
    OsRng.fill_bytes(&mut salt);
    salt
}

fn derive_key(password: &str, salt: &[u8]) -> [u8; KEY_SIZE] {
    let mut hasher = Sha256::new();
    hasher.update(password.as_bytes());
    hasher.update(salt);
    hasher.finalize().into()
}

fn save_config(config_path: &Path, config: &Config) -> Result<()> {
    let toml = toml::to_string(config).context(SerializationSnafu)?;
    OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(config_path)
        .and_then(|mut file| file.write_all(toml.as_bytes()))
        .map_err(|e| {
            if e.kind() == std::io::ErrorKind::PermissionDenied {
                Error::ReadOnlyFilesystem
            } else {
                Error::Io { source: e }
            }
        })
}

fn load_config(config_path: &Path) -> Result<Config> {
    let mut file = File::open(config_path).context(IoSnafu)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents).context(IoSnafu)?;
    toml::from_str(&contents).context(DeserializationSnafu)
}
