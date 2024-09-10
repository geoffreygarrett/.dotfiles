use std::sync::mpsc;
use std::thread;
use std::time::{Duration, Instant};

use console::Term;
use dialoguer::{theme::ColorfulTheme, Select};
use spinners::{Spinner, Spinners};

use dialogs::key_storage::check_key_storage;
use dialogs::write_confirmation::confirm_write;
use usb::detection::detect_usb_devices;
use usb::device::UsbDevice;

mod dialogs;
mod encryption;
mod usb;
mod utils;

enum UiState {
    WaitingForDevices,
    DeviceSelection(Vec<UsbDevice>),
    ProcessingDevice(UsbDevice),
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let (usb_tx, usb_rx) = mpsc::channel();
    let term = Term::stdout();

    // Spawn USB detection thread
    thread::spawn(move || {
        loop {
            let devices = detect_usb_devices();
            usb_tx.send(devices).unwrap();
            thread::sleep(Duration::from_millis(500)); // Poll every 500ms
        }
    });

    let mut ui_state = UiState::WaitingForDevices;
    let mut spinner = Spinner::new(Spinners::Dots9, "Waiting for USB devices...".into());

    loop {
        match &mut ui_state {
            UiState::WaitingForDevices => {
                if let Ok(devices) = usb_rx.recv() {
                    if !devices.is_empty() {
                        spinner.stop();
                        term.clear_screen()?;
                        ui_state = UiState::DeviceSelection(devices);
                    }
                }
            }
            UiState::DeviceSelection(devices) => {
                term.clear_screen()?;
                println!("Select a USB device (or wait for changes):");
                let theme = ColorfulTheme::default();
                let select = Select::with_theme(&theme).items(&devices).default(0);

                let start_time = Instant::now();
                let timeout = Duration::from_millis(500);

                loop {
                    if let Some(selection) = select.clone().interact_on_opt(&term)? {
                        term.clear_screen()?;
                        ui_state = UiState::ProcessingDevice(devices[selection].clone());
                        break;
                    }

                    if start_time.elapsed() >= timeout {
                        // Check for device changes
                        if let Ok(new_devices) = usb_rx.try_recv() {
                            if new_devices.is_empty() {
                                term.clear_screen()?;
                                println!("All devices unplugged. Waiting for new devices...");
                                spinner = Spinner::new(
                                    Spinners::Dots9,
                                    "Waiting for USB devices...".into(),
                                );
                                ui_state = UiState::WaitingForDevices;
                            } else if new_devices != *devices {
                                *devices = new_devices;
                                break; // Refresh the device list
                            }
                        }
                        break; // Refresh the device list anyway
                    }
                }
            }
            UiState::ProcessingDevice(device) => {
                if !confirm_write(device) {
                    term.clear_screen()?;
                    println!("Write operation cancelled. Exiting.");
                    return Ok(());
                }

                match check_key_storage(device) {
                    Ok(()) => {
                        term.clear_screen()?;
                        println!("Key storage location is ready.");
                    }
                    Err(e) => {
                        term.clear_screen()?;
                        println!("Error with key storage location: {}", e);
                        if !dialoguer::Confirm::new()
                            .with_prompt("Do you want to overwrite the existing data?")
                            .interact()?
                        {
                            term.clear_screen()?;
                            println!("Operation cancelled. Exiting.");
                            return Ok(());
                        }
                    }
                }

                term.clear_screen()?;
                spinner = Spinner::new(
                    Spinners::Dots9,
                    "Generating and storing encryption key...".into(),
                );
                thread::sleep(Duration::from_secs(3)); // Simulating key generation and storage
                spinner.stop();

                term.clear_screen()?;
                println!("USB key manager operation completed successfully.");
                return Ok(());
            }
        }

        // Check for device changes in all states
        if let Ok(new_devices) = usb_rx.try_recv() {
            match &ui_state {
                UiState::WaitingForDevices => {
                    if !new_devices.is_empty() {
                        spinner.stop();
                        term.clear_screen()?;
                        ui_state = UiState::DeviceSelection(new_devices);
                    }
                }
                UiState::DeviceSelection(_) => {
                    if new_devices.is_empty() {
                        term.clear_screen()?;
                        println!("All devices unplugged. Waiting for new devices...");
                        spinner =
                            Spinner::new(Spinners::Dots9, "Waiting for USB devices...".into());
                        ui_state = UiState::WaitingForDevices;
                    } else {
                        ui_state = UiState::DeviceSelection(new_devices);
                    }
                }
                UiState::ProcessingDevice(_) => {
                    if new_devices.is_empty() {
                        term.clear_screen()?;
                        println!("Device unplugged. Waiting for new devices...");
                        spinner =
                            Spinner::new(Spinners::Dots9, "Waiting for USB devices...".into());
                        ui_state = UiState::WaitingForDevices;
                    }
                    // If devices are still present, continue processing
                }
            }
        }
    }
}
