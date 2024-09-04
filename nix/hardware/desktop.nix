{ config, lib, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Enable NVIDIA drivers (assuming you need them for your GTX 1080 Ti)
    extraModulePackages = [ pkgs.nvidia_x11 ];

    # Additional kernel parameters can be set here, if needed
    kernelParams = [ "acpi=force" ];
  };

  # Filesystem configuration (assuming a simple setup)
  fileSystems = {
    "/" = {
      device = "/dev/sda1"; # Adjust to your root partition
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/sda2"; # Adjust to your home partition
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/sda3"; # Boot partition if separate
      fsType = "ext4";
    };
  };

  # Graphics configuration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      nvidia_x11
      libva
    ];
  };

  # Input devices configuration
  services.xserver = {
    enable = true;
    layout = "us"; # Adjust keyboard layout if necessary
    xkbOptions = "eurosign:e"; # Example XKB option
    videoDrivers = [ "nvidia" ]; # Use the NVIDIA driver
  };

  # Network configuration (already in previous examples)
  networking = {
    hostName = "geoffrey-linux-pc";
    useDHCP = false;
    interfaces.enp3s0.useDHCP = true; # Adjust to your network interface
  };

  # Enable common hardware support
  hardware.pulseaudio.enable = true; # Enable audio
  hardware.bluetooth.enable = true; # Enable Bluetooth if necessary
}
