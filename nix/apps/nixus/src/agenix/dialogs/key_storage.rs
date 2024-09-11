use std::path::Path;

use crate::usb::device::UsbDevice;

pub fn check_key_storage(device: &UsbDevice) -> Result<(), String> {
    let volume = device
        .media
        .first()
        .and_then(|m| m.volumes.first())
        .ok_or_else(|| "No volume found on the device".to_string())?;

    let key_storage_path = Path::new(&volume.mount_point).join(".usb_key_manager");
    if key_storage_path.exists() {
        Err("Key storage location already exists".to_string())
    } else {
        Ok(())
    }
}
