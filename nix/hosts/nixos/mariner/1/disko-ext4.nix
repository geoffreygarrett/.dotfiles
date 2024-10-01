{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.disk.generic-rpi4-ssd;
in
{
  options.disk.generic-rpi4-ssd = {
    labelPrefix = mkOption {
      type = types.str;
      default = "";
      description = "Prefix for disk labels";
    };

    firmwareUrl = mkOption {
      type = types.str;
      default = "https://github.com/pftf/RPi4/releases/download/v1.38/RPi4_UEFI_Firmware_v1.38.zip";
      description = "URL of the firmware to install";
    };

    firmwareSha256 = mkOption {
      type = types.str;
      default = "sha256-9tOr80jcmguFy2bSz+H3TfmG8BkKyBTFoUZkMy8x+0g=";
      description = "SHA256 hash of the firmware file";
    };

    disks = mkOption {
      type = types.listOf types.str;
      default = [ "/dev/sda" ];
      description = "List of disks to configure";
    };

    installFirmware = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install firmware on the boot partition";
    };
  };

  config =
    let
      makeLabel =
        name: if cfg.labelPrefix == "" then name else "${toUpper cfg.labelPrefix}_${toUpper name}";

      ensureFirmware = pkgs.writeShellScriptBin "install-firmware" ''
        set -euo pipefail
        FIRMWARE_DIR="${
          pkgs.fetchzip {
            url = cfg.firmwareUrl;
            sha256 = cfg.firmwareSha256;
            stripRoot = false;
          }
        }"
        BOOT_MOUNT="/mnt/boot"
        if [ ! -f "''${BOOT_MOUNT}/.firmware_installed" ]; then
          echo "Installing firmware..."
          cp -rv "''${FIRMWARE_DIR}/"* "''${BOOT_MOUNT}/"
          touch "''${BOOT_MOUNT}/.firmware_installed"
          echo "Firmware installation complete."
        else
          echo "Firmware already installed. Skipping."
        fi
      '';

      rootMountPoint = "/mnt";
    in
    {
      disko = {
        inherit rootMountPoint;
        devices.disk.main = {
          type = "disk";
          device = builtins.elemAt cfg.disks 0;
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  postMountHook = lib.optionalString cfg.installFirmware "${ensureFirmware}/bin/install-firmware";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                };
                label = makeLabel "BOOT";
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                };
                label = makeLabel "ROOT";
              };
              swap = {
                name = "swap";
                size = "2G";
                content = {
                  type = "swap";
                  randomEncryption = false;
                };
                label = makeLabel "SWAP";
              };
            };
          };
        };
      };
    };
}
