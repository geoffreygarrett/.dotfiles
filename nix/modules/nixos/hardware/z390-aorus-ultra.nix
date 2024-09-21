{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.hardware.motherboards.z390AorusUltra;
in
{
  options.hardware.motherboards.z390AorusUltra = {
    enable = mkEnableOption "Enable support for Gigabyte Z390 AORUS ULTRA motherboard";
    enableWifi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable onboard Intel CNVi 802.11ac 2x2 Wave 2 Wi-Fi";
    };
    enableBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable onboard Bluetooth";
    };
    enableRgb = mkOption {
      type = types.bool;
      default = false;
      description = "Enable RGB Fusion 2.0 support";
    };
    enableOptane = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Intel Optane memory support";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules =
        [
          "kvm-intel"
        ]
        ++ optionals cfg.enableOptane [
          "dm_cache"
          "dm_writecache"
        ]
        ++ optionals cfg.enableWifi [
          "iwlwifi"
        ];
      kernelParams = [
        "intel_iommu=on"
        "nvme_core.default_ps_max_latency_us=0" # NVMe SSD optimization
      ];
    };

    # CPU microcode updates for 8th/9th Gen Intel Core processors
    hardware.cpu.intel.updateMicrocode = true;

    # Networking: Intel Gigabit LAN with cFosSpeed
    networking.interfaces.enp0s31f6.useDHCP = true;

    # Wi-Fi: Intel CNVi 802.11ac 2x2 Wave 2
    #networking.wireless = mkIf cfg.enableWifi {
    #  enable = true;
    #  userControlled.enable = true;
    #};

    # Bluetooth
    hardware.bluetooth = lib.mkIf cfg.enableBluetooth {
      enable = true;
      powerOnBoot = true;
    };

    # audio: alc1220-vb
    # sound.enable = true; # no longer has any effect;
    #hardware.pulseaudio = {
    #  enable = true;
    #  support32bit = true;
    #  package = pkgs.pulseaudiofull;
    #};

    # usb: front & rear usb 3.1 gen 2 type-c
    #hardware.usb.enableredirectionservice = true;

    # ssd optimization: triple ultra-fast nvme pcie gen3 x4 m.2
    services.fstrim.enable = true;

    # thermal management: smart fan 5 & direct touch heatpipe
    services.thermald.enable = true;

    # rgb: rgb fusion 2.0
    hardware.i2c.enable = cfg.enablergb;
    services.hardware.openrgb.enable = cfg.enablergb;

    # power management: cec 2019 ready
    # powermanagement.enable = true;
    services.tlp.enable = true;

    # Additional packages for hardware management
    environment.systemPackages =
      with pkgs;
      [
        pciutils
        usbutils
        lm_sensors
      ]
      ++ lib.mkIf cfg.enableRgb (
        with pkgs;
        [
          openrgb
          i2c-tools
        ]
      );

  };
}
