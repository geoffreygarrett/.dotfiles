use dialoguer::Confirm;
use crate::usb::device::UsbDevice;

pub fn confirm_write(device: &UsbDevice) -> bool {
    Confirm::new()
        .with_prompt(format!("Are you sure you want to write to the device: {}?", device.name))
        .interact()
        .unwrap_or(false)
}
