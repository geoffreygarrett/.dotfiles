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

let
  hostname = "mariner-1";
in
# mainDriveUuid = "41c98998-6a08-4389-bf74-79c9efcf0739";
{
  imports = [
    # inputs.impermanence.nixosModules.impermanence
    inputs.argon40-nix.nixosModules.default
    # inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    # ./kubernetes.nix
    # impermanence.nixosModules.impermanence
    ../../../../modules/shared/secrets.nix
    ../../../../modules/nixos/tailscale.nix
    ../../../../modules/nixos/openssh.nix
    ../../../../modules/nixos/samba.nix
  ];

  system.stateVersion = "24.11";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
        "noatime"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd"
        "noatime"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

  boot.initrd.availableKernelModules = [
    # Allows early (earlier) modesetting for the Raspberry Pi
    "vc4"
    "bcm2835_dma"
    "i2c_bcm2835"

    # Maybe needed for SSD boot?
    "usb_storage"
    "xhci_pci"
    "usbhid"
    "uas"
  ];

  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=ttyAMA0,115200n8"
    "console=tty0"
    "cma=64M"
  ];

  # Add Btrfs support
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Network and firewall configuration
  networking = {
    hostName = hostname;
    useDHCP = false;
    dhcpcd.wait = "background";
    interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      secretsFile = config.sops.secrets.wireless_secrets.path;
      networks = {
        "Haemanthus" = {
          priority = 90;
          pskRaw = "ext:haemanthus_psk";
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        6443 # k3s: Kubernetes API server
        10250 # Kubelet API
      ];
      allowedUDPPorts = [
        # 8472  # Required if using Flannel in multi-node setup
      ];
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
  users.users.root.openssh.authorizedKeys.keys = keys;
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # SOPS secrets management
  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    secrets.wireless_secrets = { };
    secrets."users/${user}/password" = { };
  };

  # Trusted public keys for Nix
  nix.settings = {
    trusted-public-keys = [
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
  };
}
