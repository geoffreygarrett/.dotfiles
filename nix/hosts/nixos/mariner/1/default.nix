{
  config,
  lib,
  pkgs,
  self,
  user,
  inputs,
  keys,
  ...
}:
# nix run github:numtide/nixos-anywhere -- --flake .#mariner-1 root@mariner-1.nixus.net
let
  hostname = "mariner-1";
in
{
  imports = [
    # inputs.impermanence.nixosModules.impermanence
    # inputs.argon40-nix.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # inputs.sops-nix.nixosModules.default
    # inputs.home-manager.nixosModules.home-manager
    # ./kubernetes.nix
    # ../../../../modules/shared/secrets.nix
    # ../../../../modules/nixos/tailscale.nix
    # ../../../../modules/nixos/openssh.nix
    # ../../../../modules/nixos/samba.nix
    inputs.disko.nixosModules.disko

  ];

  disko.devices = import ./disko-ext4.nix { inherit lib; };
  # System Configuration
  system.stateVersion = "24.11";
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Boot and Filesystem Configuration
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = lib.mkForce true;
    grub.enable = false;
    generic-extlinux-compatible.enable = lib.mkForce false;
  };

  #   boot.loader.efi.canTouchEfiVariables = false;
  # boot.supportedFilesystems = [ "zfs" ];

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/ROOT";
  #     fsType = "ext4";
  #     options = [ "noatime" ];
  #   };
  #   "/boot" = {
  #     device = "/dev/disk/by-label/BOOT";
  #     fsType = "vfat";
  #   };
  # };
  # swapDevices = [
  #   { device = "/dev/disk/by-label/SWAP"; }
  # ];

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/ROOT";
  #     fsType = "btrfs";
  #     options = [
  #       "subvol=root"
  #       "compress=zstd"
  #       "noatime"
  #     ];
  #   };
  #   "/home" = {
  #     device = "/dev/disk/by-label/ROOT";
  #     fsType = "btrfs";
  #     options = [
  #       "subvol=home"
  #       "compress=zstd"
  #       "noatime"
  #     ];
  #   };
  #   "/nix" = {
  #     device = "/dev/disk/by-label/ROOT";
  #     fsType = "btrfs";
  #     options = [
  #       "subvol=nix"
  #       "compress=zstd"
  #       "noatime"
  #     ];
  #   };
  #   "/boot" = {
  #     device = "/dev/disk/by-label/BOOT";
  #     fsType = "vfat";
  #   };
  # };
  #
  # swapDevices = [
  #   { device = "/dev/disk/by-label/SWAP"; }
  # ];
  #
  # Kernel Modules and Power Management
  boot.initrd.availableKernelModules = [
    # Raspberry Pi-specific modules
    "vc4"
    "bcm2835_dma"
    "i2c_bcm2835"

    # SSD boot support
    "usb_storage"
    "xhci_pci"
    "usbhid"
    "uas"
  ];

  boot.kernelModules = [ "8021q" ];
  boot.blacklistedKernelModules = [
    "brcmfmac"
    "brcmutil"
  ];

  # boot.kernelParams = [
  #   "console=ttyS0,115200n8"
  #   "console=ttyAMA0,115200n8"
  #   "console=tty0"
  #   "cma=64M"
  # ];
  # boot.kernelParams = lib.mkForce [
  #   # https://github.com/NixOS/nixpkgs/issues/123725#issuecomment-1063370870
  #   "console=ttyS0,115200n8"
  #   "console=tty0"
  #   "kexec-load-disabled=0"
  # ];

  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=tty0"
    "noirqbalance"
    "kexec_core.loaded_kexec_image=1"
    "kexec_core.kexec_loaded=1"
    "kexec-syscall=on"
    "maxcpus=1"
    "loglevel=7"
  ];

  boot.consoleLogLevel = 7;

  # Filesystem and kernel options
  systemd.services."getty@".enable = false;
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "vfat"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Networking and Services
  systemd.services.dbus.serviceConfig.TimeoutStartSec = "120s";
  services.udev.extraRules = ''
    # Rename the interface with the MAC address to eth0
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="e4:5f:01:26:7e:ad", NAME="eth0"
  '';
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Disable Predictable Network Interface Names
  networking.usePredictableInterfaceNames = false;
  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.enabcm6e4ei0 = {
      useDHCP = true;
    };
    interfaces.eth0 = {
      useDHCP = true;
    };
  };

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = keys;
  };

  # Root user SSH authorized keys
  users.users.root.openssh.authorizedKeys.keys = keys;

  # Enable Zsh shell
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # Trusted public keys for Nix builds
  nix.settings.trusted-public-keys = [
    "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
  ];

}
