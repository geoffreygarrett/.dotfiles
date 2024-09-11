use colored::*;
use regex::Regex;
use rpassword::read_password;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use snafu::{ResultExt, Snafu};
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Debug, Snafu)]
pub enum Error {
    #[snafu(display("I/O error: {source}"))]
    Io { source: std::io::Error },
    #[snafu(display("No USB devices found"))]
    NoDevicesFound,
    #[snafu(display("Unsupported operating system"))]
    UnsupportedOS,
    #[snafu(display("Device not found"))]
    DeviceNotFound,
    #[snafu(display("Password read error: {source}"))]
    PasswordRead { source: std::io::Error },
    #[snafu(display("JSON parse error: {source}"))]
    Parse { source: serde_json::Error },
}

pub type Result<T> = std::result::Result<T, Error>;

// Data structure for a partition
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Partition {
    pub name: String,
    #[serde(default)]
    pub model: Option<String>,
    pub size: String,
    #[serde(default)]
    pub uuid: Option<String>,
    #[serde(default)]
    pub label: Option<String>,
    #[serde(rename = "fsuse%")]
    #[serde(default)]
    pub fsuse: Option<String>,
    #[serde(default)]
    pub mountpoint: Option<String>,
    #[serde(flatten)]
    pub extra: Value, // Extra field for unexpected data
}

// Impl a method to add a relative path, so we can format onto
impl Partition {
    fn add_relative_path(&mut self, path: &str) {
        if let Some(mountpoint) = &self.mountpoint {
            let new_path = Path::new(mountpoint).join(path);
            self.mountpoint = Some(new_path.to_str().unwrap().to_string());
        }
    }
}

// Data structure for a disk
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Disk {
    pub name: String,
    pub model: String,
    pub size: String,
    #[serde(default)]
    pub uuid: Option<String>,
    #[serde(default)]
    pub label: Option<String>,
    #[serde(rename = "fsuse%")]
    #[serde(default)]
    pub fsuse: Option<String>,
    pub partitions: Vec<Partition>,
    #[serde(flatten)]
    pub extra: Value, // Extra field for unexpected data
}

// Data structure to hold multiple disks
#[derive(Debug, Serialize, Deserialize)]
struct Disks {
    disks: Vec<Disk>,
}

// Main function to select the USB device and possibly a partition
pub fn select_usb_device() -> Result<(Disk, Option<Partition>)> {
    let devices = if cfg!(target_os = "macos") {
        get_usb_devices_macos()?
    } else if cfg!(target_os = "linux") {
        get_disks_linux()?.disks
    } else {
        return Err(Error::UnsupportedOS);
    };

    if devices.is_empty() {
        return Err(Error::NoDevicesFound);
    }

    println!("{}", "Available USB devices:".bold().green());
    for (i, device) in devices.iter().enumerate() {
        println!(
            "{}. {} ({}) - {} partitions",
            i + 1,
            device.name,
            device.model,
            device.partitions.len()
        );
    }

    // Select a disk
    let disk_selection = loop {
        print!("Select a USB device (1-{}): ", devices.len());
        io::stdout().flush().context(IoSnafu)?;
        let mut input = String::new();
        io::stdin().read_line(&mut input).context(IoSnafu)?;
        if let Ok(num) = input.trim().parse::<usize>() {
            if num > 0 && num <= devices.len() {
                break num - 1;
            }
        }
        println!("Invalid selection. Please try again.");
    };

    let selected_disk = devices[disk_selection].clone();

    // Check if the disk has multiple partitions
    if selected_disk.partitions.len() > 1 {
        println!(
            "{}",
            "The selected device has multiple partitions:"
                .bold()
                .yellow()
        );
        for (i, partition) in selected_disk.partitions.iter().enumerate() {
            println!(
                "{}. {} - Size: {} - Mountpoint: {:?}",
                i + 1,
                partition.name,
                partition.size,
                partition.mountpoint
            );
        }

        let partition_selection = loop {
            print!(
                "Select a partition (1-{}): ",
                selected_disk.partitions.len()
            );
            io::stdout().flush().context(IoSnafu)?;
            let mut input = String::new();
            io::stdin().read_line(&mut input).context(IoSnafu)?;
            if let Ok(num) = input.trim().parse::<usize>() {
                if num > 0 && num <= selected_disk.partitions.len() {
                    break num - 1;
                }
            }
            println!("Invalid selection. Please try again.");
        };

        Ok((
            selected_disk.clone(),
            Some(selected_disk.partitions[partition_selection].clone()),
        ))
    } else {
        Ok((selected_disk.clone(), None))
    }
}

// Function to get USB devices on macOS
fn get_usb_devices_macos() -> Result<Vec<Disk>> {
    let output = Command::new("diskutil")
        .arg("list")
        .output()
        .context(IoSnafu)?;

    let disk_list = String::from_utf8_lossy(&output.stdout);
    let re = Regex::new(r"/dev/disk\d+").unwrap();
    let mut devices = Vec::new();

    // Iterate through detected disks
    for disk in re.find_iter(&disk_list) {
        let info_output = Command::new("diskutil")
            .args(&["info", disk.as_str()])
            .output()
            .context(IoSnafu)?;

        let info = String::from_utf8_lossy(&info_output.stdout);

        // Check if the device is a removable media
        if info.contains("Removable Media:") && info.contains("Yes") {
            let model = info
                .lines()
                .find(|line| line.contains("Device / Media Name:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.trim().to_string())
                .unwrap_or("Unknown".to_string());

            let size = info
                .lines()
                .find(|line| line.contains("Disk Size:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.split_whitespace().next().unwrap_or("").to_string())
                .unwrap_or("0B".to_string());

            let uuid = info
                .lines()
                .find(|line| line.contains("Volume UUID:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.trim().to_string());

            let mountpoint = info
                .lines()
                .find(|line| line.contains("Mount Point:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.trim().to_string());

            let label = info
                .lines()
                .find(|line| line.contains("Volume Name:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.trim().to_string());

            let fsuse = info
                .lines()
                .find(|line| line.contains("Capacity Used:"))
                .and_then(|line| line.split(":").nth(1))
                .map(|s| s.trim().to_string());

            // Create partition and disk objects
            let partition = Partition {
                name: disk.as_str().to_string(),
                model: Some(model.clone()),
                size: size.clone(),
                uuid: uuid.clone(),
                label: label.clone(),
                fsuse,
                mountpoint,
                extra: serde_json::json!({}),
            };

            let disk = Disk {
                name: disk.as_str().to_string(),
                model,
                size,
                uuid,
                label,
                fsuse: None,
                partitions: vec![partition],
                extra: serde_json::json!({}),
            };

            devices.push(disk);
        }
    }

    Ok(devices)
}

// Function to get USB devices on Linux
fn get_disks_linux() -> Result<Disks> {
    let output = Command::new("sh")
        .arg("-c")
        .arg(
            r#"lsblk --paths --json -no NAME,MODEL,SIZE,UUID,LABEL,FSUSE%,MOUNTPOINT,TYPE | jq '{
            disks: [.blockdevices[] | select(.type=="disk") | {
                name: .name,
                model: .model,
                size: .size,
                uuid: .uuid,
                label: .label,
                fsuse: .["fsuse%"],
                partitions: [.children[] | {
                    name: .name,
                    model: .model,
                    size: .size,
                    uuid: .uuid,
                    label: .label,
                    fsuse: .["fsuse%"],
                    mountpoint: .mountpoint,
                    type: .type
                }]
            }]
        }'"#,
        )
        .output()
        .context(IoSnafu)?;

    if !output.status.success() {
        eprintln!("Error running `lsblk` command.");
        return Err(Error::Io {
            source: io::Error::new(io::ErrorKind::Other, "Command failed"),
        });
    }

    let parsed: Disks = serde_json::from_slice(&output.stdout).context(ParseSnafu)?;
    Ok(parsed)
}

pub fn get_password(prompt: &str) -> Result<String> {
    print!("{}", prompt);
    io::stdout().flush().context(IoSnafu)?;
    read_password().context(PasswordReadSnafu)
}
