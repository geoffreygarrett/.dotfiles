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
# =======
# {
#   description = "NixOS SD Image Build and Flash Scripts";
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils";
#   };
#
#   outputs =
#     {
#       self,
#       nixpkgs,
#       flake-utils,
#     }:
#     flake-utils.lib.eachDefaultSystem (
#       system:
#       let
#         pkgs = import nixpkgs { inherit system; };
#         lib = pkgs.lib;
#
#         commonInputs = with pkgs; [
#           coreutils
#           gnutar
#           gzip
#           zstd
#           util-linux
#           nixFlakes
#           jq
#         ];
#
#         sharedFunctions = ''
#           die() { echo "Error: $1" >&2; exit 1; }
#
#           confirm() {
#             read -p "$1 (y/N) " response
#             case "$response" in
#               [yY]*) return 0 ;;
#               *) return 1 ;;
#             esac
#           }
#
#           get_targets() {
#             nix flake show --json |
#             jq -r '.nixosConfigurations | to_entries[] |
#             select(.value | has("config") and .config | has("system") and .system | has("build") and .build | has("sdImage")) |
#             .key'
#           }
#
#           select_target() {
#             local targets=($(get_targets))
#             [[ ''${#targets[@]} -eq 0 ]] && die "No valid targets found with sdImage configuration."
#
#             echo "Select a target to build:"
#             select target in "''${targets[@]}"; do
#               [[ -n "$target" ]] && { echo "$target"; return; }
#               echo "Invalid selection. Please try again."
#             done
#           }
#         '';
#
#         buildScript = pkgs.writeShellScriptBin "build-sd-image" ''
#           ${sharedFunctions}
#
#           build_image() {
#             local target="$1"
#             echo "Building SD image for $target..."
#             nix build ".#nixosConfigurations.$target.config.system.build.sdImage" --show-trace ||
#               die "Build failed for $target"
#             echo "Build complete for $target"
#           }
#
#           main() {
#             local target=$(select_target)
#             build_image "$target"
#           }
#
#           main "$@"
#         '';
#
#         flashScript = pkgs.writeShellScriptBin "flash-sd-image" ''
#           ${sharedFunctions}
#
#           IMAGE_PATH=$(echo result/sd-image/nixos-sd-image-*-aarch64-linux.img)
#           SD_CARD="/dev/sdb"
#
#           check_root() {
#             [[ $EUID -ne 0 ]] && die "This script must be run as root"
#           }
#
#           detect_and_flash_image() {
#             local compression
#             case "$(od -An -N4 -tx1 "$IMAGE_PATH" | tr -d ' ')" in
#               28b52ffd) compression="zstd" ;;
#               1f8b*) compression="gzip" ;;
#               *) compression="none" ;;
#             esac
#
#             echo "Flashing ''${compression} compressed image..."
#             case "$compression" in
#               zstd) zstd -dcf "$IMAGE_PATH" | dd of="$SD_CARD" bs=4M status=progress conv=fsync ;;
#               gzip) zcat "$IMAGE_PATH" | dd of="$SD_CARD" bs=4M status=progress conv=fsync ;;
#               none) dd if="$IMAGE_PATH" of="$SD_CARD" bs=4M status=progress conv=fsync ;;
#             esac
#           }
#
#           unmount_partitions() {
#             for partition in ${SD_CARD}*; do
#               if mount | grep -q "$partition"; then
#                 echo "Unmounting $partition"
#                 umount "$partition" || die "Failed to unmount $partition"
#               fi
#             done
#           }
#
#           main() {
#             check_root
#             confirm "This will erase all data on $SD_CARD. Continue?" || die "Aborted by user."
#             unmount_partitions
#             detect_and_flash_image
#             sync
#             echo "Flashing complete. You can now remove the SD card."
#           }
#
#           main "$@"
#         '';
#
#         buildFlashScript = pkgs.writeShellScriptBin "build-and-flash-sd-image" ''
#           ${sharedFunctions}
#
#           main() {
#             ${buildScript}/bin/build-sd-image
#             ${flashScript}/bin/flash-sd-image
#           }
#
#           main "$@"
#         '';
#
#       in
#       {
#         packages = {
#           inherit buildScript flashScript buildFlashScript;
#           default = buildFlashScript;
#         };
#       }
#     );
# }
