{
  lib ? import <nixpkgs/lib>,
  pkgs ? import <nixpkgs> { },
  ...
}@args:

let
  cfg = {
    labelPrefix = "";
    firmwareUrl = "https://github.com/pftf/RPi3/releases/download/v1.39/RPi3_UEFI_Firmware_v1.39.zip";
    firmwareSha256 = "sha256-mfMlRJyROmGijFeImvQxsxKQH5za1df3GX8W0iIMcfo=";
    disks = [ "/dev/sde" ];
    installFirmware = true;
  };

  makeLabel =
    name: if cfg.labelPrefix == "" then name else "${lib.toUpper cfg.labelPrefix}_${lib.toUpper name}";

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

in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt cfg.disks 0;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              type = "EF00";
              size = "512M";
              content =
                {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                    "noatime"
                  ];
                }
                // lib.optionalAttrs cfg.installFirmware {
                  postMountHook = "${ensureFirmware}/bin/install-firmware";
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
