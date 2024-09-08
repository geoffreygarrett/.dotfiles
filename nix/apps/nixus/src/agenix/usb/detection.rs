use std::process::Command;

use serde_json::Value;

use super::device::{UsbController, UsbDevice};

pub fn detect_usb_devices() -> Vec<UsbDevice> {
    let usb_controllers = get_usb_devices();
    find_usb_storage_devices(usb_controllers.as_slice())
}


fn get_usb_devices() -> Vec<UsbController> {
    let output = Command::new("system_profiler")
        .arg("SPUSBDataType")
        .arg("-json")
        .output()
        .expect("Failed to execute system_profiler");

    let output_str = String::from_utf8_lossy(&output.stdout);
    let json_value: Value = serde_json::from_str(&output_str).expect("Failed to parse JSON");
    let usb_data = json_value.get("SPUSBDataType").unwrap_or(&Value::Null);

    serde_json::from_value(usb_data.clone()).unwrap_or_else(|_| vec![])
}

// Function to extract USB storage devices from a list of USB controllers
pub fn find_usb_storage_devices(usb_controllers: &[UsbController]) -> Vec<UsbDevice> {
    usb_controllers
        .iter()
        .filter_map(|controller| controller.items.as_ref())  // Extract hubs from the controller
        .flat_map(|hubs| hubs.iter())  // Iterate through the hubs
        .filter_map(|hub| hub.items.as_ref())  // Extract devices from hubs
        .flat_map(|devices| devices.clone())  // Clone the devices to return owned data
        .collect()  // Collect the devices into a Vec<UsbDevice>
}
