#!/usr/bin/env bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Unicode characters
CHECK_MARK='\u2714'
CROSS_MARK='\u2718'
ARROW='\u2192'

TAILS_URL="https://download.tails.net/tails/stable/tails-amd64-6.7/tails-amd64-6.7.img"
TAILS_SIG_URL="${TAILS_URL}.sig"
TAILS_KEY_URL="https://tails.net/tails-signing.key"
TAILS_IMG="tails-amd64-6.7.img"
TAILS_SIG="${TAILS_IMG}.sig"

print_header() {
    echo -e "${BOLD}${BLUE}=======================================${NC}"
    echo -e "${BOLD}${BLUE}       Tails USB Creator Script        ${NC}"
    echo -e "${BOLD}${BLUE}=======================================${NC}"
}

print_step() {
    echo -e "\n${BOLD}${MAGENTA}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK_MARK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS_MARK} Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

print_header

print_step "Checking sudo privileges"
if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run with sudo privileges. Please use: sudo $0"
    exit 1
fi
print_success "Script is running with sudo privileges."

OS="$(uname)"
print_success "Detected operating system: ${CYAN}$OS${NC}"

declare -a usb_devices

list_usb_devices_linux() {
    print_step "Scanning for available USB devices on Linux"
    echo "Debug: Running lsblk command..."
    lsblk -d -o NAME,SIZE,MODEL,TRAN,TYPE,RM,MOUNTPOINT

    # Use `lsblk` to list only removable block devices
    local devices=($(lsblk -dnro NAME,SIZE,MODEL,TRAN,TYPE,RM | awk '$6 == 1 && $5 == "disk" && $4 == "usb" {print $1","$2","$3}'))

    local count=1
    for device_info in "${devices[@]}"; do
        IFS=',' read -r name size model <<< "$device_info"
        echo -e "${CYAN}$count)${NC} /dev/$name - $size - $model"
        usb_devices+=("/dev/$name")
        count=$((count+1))
    done

    if [ ${#usb_devices[@]} -eq 0 ]; then
        echo "Debug: No removable USB devices found. Here's the output of 'lsblk -d':"
        lsblk -d
    fi
}

list_usb_devices_macos() {
    print_step "Scanning for available USB devices on macOS"
    echo "Debug: Running diskutil list..."
    diskutil list

    local IFS=$'\n'
    local disks=($(diskutil list | grep '^/dev/disk'))
    local count=1
    for disk in "${disks[@]}"; do
        local diskname=$(echo "$disk" | awk '{print $1}')
        echo "Debug: Checking $diskname"
        local diskinfo=$(diskutil info "$diskname")
        local is_internal=$(echo "$diskinfo" | grep "Internal" | awk '{print $2}')
        local is_ejectable=$(echo "$diskinfo" | grep "Ejectable" | awk '{print $2}')
        local is_removable=$(echo "$diskinfo" | grep "Removable Media" | awk '{print $3}')
        if [ "$is_internal" = "No" ] && { [ "$is_ejectable" = "Yes" ] || [ "$is_removable" = "Yes" ]; }; then
            local size=$(echo "$diskinfo" | grep "Disk Size" | head -n 1 | awk -F'(' '{print $2}' | sed 's/)//')
            local model=$(echo "$diskinfo" | grep "Device / Media Name" | awk -F: '{print $2}' | xargs)
            echo -e "${CYAN}$count)${NC} $diskname - $size - $model"
            usb_devices+=("$diskname")
            count=$((count+1))
        else
            echo "Debug: Skipping $diskname (internal or non-removable)"
        fi
    done

    if [ ${#usb_devices[@]} -eq 0 ]; then
        echo "Debug: No removable USB devices found. Here's the output of 'diskutil list':"
        diskutil list
    fi
}

unmount_device_linux() {
    print_step "Unmounting partitions on $USB_DEVICE"
    local mountpoints=$(lsblk -nro MOUNTPOINT "$USB_DEVICE")
    for mp in $mountpoints; do
        if [ -n "$mp" ]; then
            echo -e "${ARROW} Unmounting $mp..."
            umount "$mp"
        fi
    done
    print_success "All partitions on $USB_DEVICE have been unmounted."
}

# Main script
if [ "$OS" = "Linux" ]; then
    list_usb_devices_linux
elif [ "$OS" = "Darwin" ]; then
    list_usb_devices_macos
else
    print_error "Unsupported OS: $OS"
    exit 1
fi

if [ ${#usb_devices[@]} -eq 0 ]; then
    print_error "No removable USB devices found. Please connect a USB drive and try again."
    exit 1
fi

echo -e "\n${BOLD}Please select a USB device to flash Tails to (enter the number):${NC}"
read selection

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#usb_devices[@]}" ]; then
    print_error "Invalid selection."
    exit 1
fi

USB_DEVICE="${usb_devices[$((selection - 1))]}"

echo -e "\nYou have selected: ${CYAN}$USB_DEVICE${NC}"

# Additional safety checks
print_step "Performing safety checks"

if [ "$OS" = "Linux" ]; then
    if grep -qs "$USB_DEVICE" /proc/mounts; then
        print_warning "The selected device is currently mounted. It will be unmounted before proceeding."
    fi

    if [ "$(lsblk -ndo TRAN "$USB_DEVICE")" != "usb" ]; then
        print_error "The selected device is not a USB device. Aborting for safety."
        exit 1
    fi

    ROOT_DEVICE=$(findmnt -no SOURCE /)
    if [[ "$USB_DEVICE" == "$ROOT_DEVICE"* ]]; then
        print_error "The selected device contains the root filesystem. Aborting for safety."
        exit 1
    fi
elif [ "$OS" = "Darwin" ]; then
    SYSTEM_DISK=$(df / | tail -1 | awk '{print $1}')
    if [[ "$USB_DEVICE" == "$SYSTEM_DISK"* ]]; then
        print_error "The selected device contains the system filesystem. Aborting for safety."
        exit 1
    fi
fi

print_warning "This will erase all data on $USB_DEVICE"
echo -e "${BOLD}Please type 'YES' (in uppercase) to confirm and continue:${NC}"
read confirmation

if [ "$confirmation" != "YES" ]; then
    echo "Aborting."
    exit 1
fi

# Function to download files
download_file() {
    url="$1"
    output="$2"
    echo -e "${ARROW} Downloading ${CYAN}$output${NC} from ${CYAN}$url${NC}..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$output" "$url" --progress-bar
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$output" "$url" --show-progress
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    print_success "Download of $output completed."
}

# Download Tails image and signature
print_step "Downloading Tails image and signature"
download_file "$TAILS_URL" "$TAILS_IMG"
download_file "$TAILS_SIG_URL" "$TAILS_SIG"

# Download and import Tails signing key
print_step "Downloading and importing Tails signing key"
download_file "$TAILS_KEY_URL" "tails-signing.key"
gpg --import tails-signing.key
print_success "Tails signing key imported successfully."

# Verify the signature
print_step "Verifying Tails image signature"
if gpg --verify "$TAILS_SIG" "$TAILS_IMG"; then
    print_success "Signature verified successfully."
else
    print_error "Signature verification failed. Aborting."
    exit 1
fi

# Unmount device
if [ "$OS" = "Darwin" ]; then
    # Use raw disk
    USB_DEVICE_RAW="${USB_DEVICE/disk/rdisk}"
    print_step "Unmounting $USB_DEVICE"
    diskutil unmountDisk "$USB_DEVICE"
    USB_DEVICE="$USB_DEVICE_RAW"
    print_success "Using raw disk device: $USB_DEVICE"
else
    print_step "Unmounting $USB_DEVICE partitions"
    unmount_device_linux
fi

# Flash the image to USB
print_step "Flashing Tails image to $USB_DEVICE"
echo -e "${YELLOW}This may take a while. Please be patient and do not interrupt the process.${NC}"
if [ "$OS" = "Darwin" ]; then
    dd if="$TAILS_IMG" of="$USB_DEVICE" bs=4m status=progress
else
    dd if="$TAILS_IMG" of="$USB_DEVICE" bs=4M conv=fdatasync status=progress
fi

print_success "Tails USB created successfully!"

# Clean up
print_step "Cleaning up temporary files"
rm -f "$TAILS_IMG" "$TAILS_SIG" "tails-signing.key"
print_success "Cleanup completed."

echo -e "\n${BOLD}${GREEN}Tails USB creation process finished. You can now use your Tails USB drive.${NC}"