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
{
  imports = [
    # Uncomment if you need impermanence
    # inputs.impermanence.nixosModules.impermanence
    inputs.argon40-nix.nixosModules.default
    # inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    # Additional configurations
    # ./kubernetes.nix
    # impermanence.nixosModules.impermanence
    ../../../../modules/shared/secrets.nix
    ../../../../modules/nixos/tailscale.nix
    ../../../../modules/nixos/openssh.nix
    ../../../../modules/nixos/samba.nix
  ];

  system.stateVersion = "24.11";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    grub.enable = false;
  };

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
      options = [ "noauto" ]; # Only mount when needed
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

  # Kernel and boot modules
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

  # Enable mingetty for HDMI (TTY1)
  services.mingetty = {
    enable = true; # Ensures TTY1 is active for login via HDMI
    tty = "tty1"; # Default console for HDMI
    autoLogin = false; # Set true if you want auto-login
  };

  boot.kernelParams = [
    "console=tty1" # Ensures the console output goes to tty1
    "console=ttyS0,115200n8" # If you need serial console
    "console=ttyAMA0,115200n8" # Serial console for Raspberry Pi
  ];

  # Filesystem and kernel options
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Power management
  powerManagement.cpuFreqGovernor = "ondemand";

  # Networking configuration
  networking = {
    hostName = hostname;
    networkmanager.enable = true;

    # Enable Ethernet (end0) with DHCP
    interfaces.end0.useDHCP = true;

    # Uncomment if using Ethernet and Wi-Fi with DHCP
    # interfaces.end0.useDHCP = true;
    # interfaces.wlan0.useDHCP = true;

    # Uncomment if you need wireless configuration
    # wireless = {
    #   enable = true;
    #   userControlled.enable = true;
    #   secretsFile = config.sops.secrets.wireless_secrets.path;
    #   networks = {
    #     "Haemanthus" = {
    #       priority = 90;
    #       pskRaw = "ext:haemanthus_psk";
    #     };
    #   };
    # };

    # Firewall settings
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
        # Uncomment if using Flannel in multi-node setup
        # 8472
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

  # Root user SSH authorized keys
  users.users.root.openssh.authorizedKeys.keys = keys;

  # Enable Zsh shell
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # SOPS secrets management
  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    secrets.wireless_secrets = { };
  };

  # Trusted public keys for Nix builds
  nix.settings.trusted-public-keys = [
    "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
  ];
}
