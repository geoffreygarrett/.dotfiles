#!/bin/sh
set -e

IMAGE_PATH=$(echo result-mariner-2/sd-image/nixos-sd-image-*-aarch64-linux.img)
SD_CARD="/dev/sda"  # Make sure this is the correct device for your SD card

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# Function to detect image type and flash accordingly
flash_image() {
    # Check if the file starts with the zstd magic number
    if [ "$(od -An -N4 -tx1 "$IMAGE_PATH" | tr -d ' ')" = "28b52ffd" ]; then
        echo "Flashing zstd compressed image..."
        zstd -dcf "$IMAGE_PATH" | dd of="$SD_CARD" bs=4M status=progress conv=fsync
        # Check if the file starts with the gzip magic number
    elif [ "$(od -An -N2 -tx1 "$IMAGE_PATH" | tr -d ' ')" = "1f8b" ]; then
        echo "Flashing gzip compressed image..."
        zcat "$IMAGE_PATH" | dd of="$SD_CARD" bs=4M status=progress conv=fsync
        # Assume it's an uncompressed image if it doesn't match the above
    else
        echo "Flashing uncompressed image..."
        dd if="$IMAGE_PATH" of="$SD_CARD" bs=4M status=progress conv=fsync
    fi
}

# Main execution
check_root

echo "This script will flash the NixOS image to $SD_CARD"
echo "All data on $SD_CARD will be erased!"
printf "Are you sure you want to continue? (y/N) "
read -r REPLY
if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    echo "Aborting."
    exit 1
fi

# Unmount any partitions of the SD card
for partition in ${SD_CARD}*; do
    if mount | grep -q "$partition"; then
        echo "Unmounting $partition"
        umount "$partition"
    fi
done

flash_image
sync

echo "Flashing complete. You can now safely remove the SD card."
