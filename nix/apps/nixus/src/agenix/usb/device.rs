use std::fmt;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct VolumeInfo {
    #[serde(rename = "_name")]
    pub name: String,
    #[serde(rename = "bsd_name")]
    pub bsd_name: String,
    #[serde(rename = "file_system")]
    pub file_system: String,
    #[serde(rename = "free_space")]
    pub free_space: String,
    #[serde(rename = "free_space_in_bytes")]
    pub free_space_in_bytes: i64,
    #[serde(rename = "iocontent")]
    pub iocontent: String,
    #[serde(rename = "mount_point")]
    pub mount_point: String,
    #[serde(rename = "size")]
    pub size: String,
    #[serde(rename = "size_in_bytes")]
    pub size_in_bytes: i64,
    #[serde(rename = "volume_uuid")]
    pub volume_uuid: String,
    #[serde(rename = "writable")]
    pub writable: String,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct MediaInfo {
    #[serde(rename = "_name")]
    pub name: String,
    #[serde(rename = "bsd_name")]
    pub bsd_name: String,
    #[serde(rename = "Logical Unit")]
    pub logical_unit: i64,
    #[serde(rename = "partition_map_type")]
    pub partition_map_type: String,
    #[serde(rename = "removable_media")]
    pub removable_media: String,
    #[serde(rename = "size")]
    pub size: String,
    #[serde(rename = "size_in_bytes")]
    pub size_in_bytes: i64,
    #[serde(rename = "smart_status")]
    pub smart_status: String,
    #[serde(rename = "USB Interface")]
    pub usb_interface: i64,
    #[serde(rename = "volumes")]
    pub volumes: Vec<VolumeInfo>,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct UsbDevice {
    #[serde(rename = "_name")]
    pub name: String,
    #[serde(rename = "bcd_device")]
    pub bcd_device: String,
    #[serde(rename = "bus_power")]
    pub bus_power: String,
    #[serde(rename = "bus_power_used")]
    pub bus_power_used: String,
    #[serde(rename = "device_speed")]
    pub device_speed: String,
    #[serde(rename = "extra_current_used")]
    pub extra_current_used: String,
    #[serde(rename = "location_id")]
    pub location_id: String,
    #[serde(rename = "manufacturer")]
    pub manufacturer: String,
    #[serde(rename = "Media")]
    pub media: Vec<MediaInfo>,
    #[serde(rename = "product_id")]
    pub product_id: String,
    #[serde(rename = "serial_num")]
    pub serial_num: String,
    #[serde(rename = "vendor_id")]
    pub vendor_id: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct UsbHub {
    #[serde(rename = "_name")]
    pub name: String,
    #[serde(rename = "bcd_device")]
    pub bcd_device: String,
    #[serde(rename = "bus_power")]
    pub bus_power: String,
    #[serde(rename = "bus_power_used")]
    pub bus_power_used: String,
    #[serde(rename = "device_speed")]
    pub device_speed: String,
    #[serde(rename = "extra_current_used")]
    pub extra_current_used: String,
    #[serde(rename = "location_id")]
    pub location_id: String,
    #[serde(rename = "manufacturer")]
    pub manufacturer: String,
    #[serde(rename = "product_id")]
    pub product_id: String,
    #[serde(rename = "vendor_id")]
    pub vendor_id: String,
    #[serde(rename = "_items")]
    pub items: Option<Vec<UsbDevice>>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct UsbController {
    #[serde(rename = "_name")]
    pub name: String,
    #[serde(rename = "host_controller")]
    pub host_controller: String,
    #[serde(rename = "_items")]
    pub items: Option<Vec<UsbHub>>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct UsbReport {
    #[serde(rename = "SPUSBDataType")]
    pub usb_data: Vec<UsbController>,
}

#[derive(Debug)]
#[allow(dead_code)]
pub enum UsbItem<'a> {
    Hub(&'a UsbHub),
    Device(&'a UsbDevice),
}

impl fmt::Display for UsbDevice {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{} {} - {} - {} - ID {}:{}",
            get_device_class_emoji(0x08), // Assuming Mass Storage
            self.name,
            self.manufacturer,
            self.media
                .first()
                .map(|m| m.size.as_str())
                .unwrap_or("Unknown Size"),
            self.vendor_id.split_whitespace().next().unwrap_or(""),
            self.product_id
        )
    }
}

fn get_device_class_emoji(class_code: u8) -> &'static str {
    match class_code {
        0x00 => "❓", // Unspecified
        0x01 => "🎵", // Audio
        0x02 => "📞", // Communications
        0x03 => "🖱️", // Human Interface
        0x05 => "🏋️", // Physical
        0x06 => "📷", // Image
        0x07 => "🖨️", // Printer
        0x08 => "💾", // Mass Storage
        0x09 => "🔌", // Hub
        0x0A => "📊", // CDC-Data
        0x0B => "💳", // Smart Card
        0x0D => "🔒", // Content Security
        0x0E => "🎥", // Video
        0x0F => "🩺", // Personal Healthcare
        0xDC => "🔍", // Diagnostic Device
        0xE0 => "📡", // Wireless
        0xEF => "🔧", // Miscellaneous
        0xFE => "🎯", // Application Specific
        0xFF => "🏷️", // Vendor Specific
        _ => "❓",    // Unknown
    }
}
