#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! rusb = "0.9.4"
//! dialoguer = "0.10.3"
//! console = "0.15.8"
//! ```

use console::Style;
use dialoguer::{theme::ColorfulTheme, Select};
use rusb::{Device, DeviceDescriptor, GlobalContext};

fn main() {
    // Scan for USB devices
    let devices = match rusb::devices() {
        Ok(devices) => devices,
        Err(e) => {
            eprintln!("Failed to list devices: {}", e);
            return;
        }
    };

    // Create a list of USB devices with their details
    let mut device_list: Vec<String> = vec![];
    for device in devices.iter() {
        if let Ok(device_desc) = device.device_descriptor() {
            device_list.push(format_device_info(&device, &device_desc));
        }
    }

    if device_list.is_empty() {
        println!("No USB devices found.");
        return;
    }

    // Define the theme for the prompt
    let theme = ColorfulTheme {
        checked_item_prefix: Style::new().green().bold().apply_to("[✔]".to_string()),
        unchecked_item_prefix: Style::new().red().apply_to("[ ]".to_string()),
        active_item_style: Style::new().yellow().bold(),
        inactive_item_style: Style::new(),
        ..ColorfulTheme::default()
    };

    // Display a legend for how to interact with the dialog
    println!("\nLegend:");
    println!("  ↑/↓ - Navigate");
    println!("  Enter - Select");

    // Create a single-select prompt (user can select only one USB device)
    let selection = Select::with_theme(&theme)
        .with_prompt("Select a USB device to use:")
        .items(&device_list)
        .interact()
        .unwrap();

    // Styling for the selected item
    let selected_style = Style::new().green().bold();

    // Print the selected device
    println!("\nYou selected:");
    println!("{}", selected_style.apply_to(&device_list[selection]));
}

// Helper function to format device information
fn format_device_info(device: &Device<GlobalContext>, desc: &DeviceDescriptor) -> String {
    format!(
        "Bus {:03} Device {:03} ID {:04x}:{:04x} - {}",
        device.bus_number(),
        device.address(),
        desc.vendor_id(),
        desc.product_id(),
        get_device_class(desc.class_code())
    )
}

// Helper function to get the device class as a string
fn get_device_class(class_code: u8) -> &'static str {
    match class_code {
        0x00 => "Unspecified",
        0x01 => "Audio",
        0x02 => "Communications",
        0x03 => "Human Interface",
        0x05 => "Physical",
        0x06 => "Image",
        0x07 => "Printer",
        0x08 => "Mass Storage",
        0x09 => "Hub",
        0x0A => "CDC-Data",
        0x0B => "Smart Card",
        0x0D => "Content Security",
        0x0E => "Video",
        0x0F => "Personal Healthcare",
        0xDC => "Diagnostic Device",
        0xE0 => "Wireless",
        0xEF => "Miscellaneous",
        0xFE => "Application Specific",
        0xFF => "Vendor Specific",
        _ => "Unknown",
    }
}
