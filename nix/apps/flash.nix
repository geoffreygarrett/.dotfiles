{ pkgs }:
let
  script = pkgs.writeShellApplication {
    name = "nixos-sd-flasher";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
      zstd
      gzip
      gnugrep
      parted
      dosfstools
    ];
    text = ''
      set -euo pipefail
      IMAGE_PATH=""
      TARGET=""
      # Parse command line arguments
      while [[ $# -gt 0 ]]; do
        case $1 in
          --image-path)
            IMAGE_PATH="$2"
            shift 2
            ;;
          --target)
            TARGET="$2"
            shift 2
            ;;
          *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        esac
      done
      if [ -z "$IMAGE_PATH" ] || [ -z "$TARGET" ]; then
        echo "Usage: $0 --image-path <path-to-image> --target <device-or-file>" >&2
        exit 1
      fi

      # Function to check if the target is a block device or a file
      check_target() {
        if [ -b "$TARGET" ]; then
          echo "$TARGET is a block device."
          TARGET_TYPE="block"
        elif [ -c "$TARGET" ]; then
          echo "$TARGET is a character device."
          TARGET_TYPE="char"
        elif [ -f "$TARGET" ]; then
          echo "$TARGET is a regular file."
          TARGET_TYPE="file"
        else
          echo "Error: $TARGET is neither a block device, character device, nor a regular file." >&2
          exit 1
        fi
      }

      # Function to check if there's enough space
      check_space() {
        local image_size
        local target_size
        image_size=$(stat -c %s "$IMAGE_PATH")
        if [ "$TARGET_TYPE" = "block" ] || [ "$TARGET_TYPE" = "char" ]; then
          target_size=$(blockdev --getsize64 "$TARGET" 2>/dev/null || echo 0)
          if [ "$target_size" -eq 0 ]; then
            echo "Warning: Unable to determine size of $TARGET. Proceeding without size check."
            return
          fi
        else
          target_size=$(stat -c %s "$TARGET")
        fi
        echo "Image size: $image_size bytes"
        echo "Target size: $target_size bytes"
        if [ "$image_size" -gt "$target_size" ]; then
          echo "Error: The image size ($image_size bytes) is larger than the target capacity ($target_size bytes)." >&2
          exit 1
        fi
      }

      # Function to detect image type and flash accordingly
      flash_image() {
        local magic_number
        magic_number=$(od -An -N4 -tx1 "$IMAGE_PATH" | tr -d ' ')
        case "$magic_number" in
          28b52ffd)
            echo "Flashing zstd compressed image..."
            zstd -dcf "$IMAGE_PATH" | dd of="$TARGET" bs=4M status=progress conv=fsync
            ;;
          1f8b*)
            echo "Flashing gzip compressed image..."
            zcat "$IMAGE_PATH" | dd of="$TARGET" bs=4M status=progress conv=fsync
            ;;
          *)
            echo "Flashing uncompressed image..."
            dd if="$IMAGE_PATH" of="$TARGET" bs=4M status=progress conv=fsync
            ;;
        esac
      }

      check_target
      check_space
      echo "This script will flash the NixOS image to $TARGET"
      echo "All data on $TARGET will be overwritten!"
      printf "Are you sure you want to continue? (y/N) "
      read -r REPLY
      if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
        echo "Aborting."
        exit 1
      fi

      # Unmount any partitions if target is a block device
      if [ "$TARGET_TYPE" = "block" ]; then
        for partition in "$TARGET"*; do
          if mount | grep -q "$partition"; then
            echo "Unmounting $partition"
            umount "$partition"
          fi
        done
      fi

      flash_image
      sync
      echo "Flashing complete. If $TARGET is a removable device, you can now safely remove it."
    '';
  };
in
script
