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
    # inputs.impermanence.nixosModules.impermanence
    inputs.argon40-nix.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.default
    # inputs.home-manager.nixosModules.home-manager
    # ./kubernetes.nix
    ../../../../modules/shared/secrets.nix
    ../../../../modules/nixos/tailscale.nix
    ../../../../modules/nixos/openssh.nix
    ../../../../modules/nixos/samba.nix
  ];

  system.stateVersion = "24.11";

  # Boot and Filesystem Configuration
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = lib.mkForce true;
    grub.enable = false;
    generic-extlinux-compatible.enable = lib.mkForce false;
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
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

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

  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=ttyAMA0,115200n8"
    "console=tty0"
    "cma=64M"
  ];

  # Filesystem and kernel options
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Networking and Services
  services.dbus.enable = true;
  systemd.services.dbus.serviceConfig.TimeoutStartSec = "120s";
  services.udev.extraRules = ''
    # Rename the interface with the MAC address to eth0
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="e4:5f:01:26:7e:ad", NAME="eth0"
  '';

  # Disable Predictable Network Interface Names
  networking.usePredictableInterfaceNames = false;

  # # Networking configuration
  # networking = {
  #   hostName = hostname;
  #   networkmanager.enable = true;
  #
  #   # Enable Ethernet (end0) with DHCP
  #   interfaces.end0.useDHCP = true;
  #
  #   # Uncomment if using Ethernet and Wi-Fi with DHCP
  #   # interfaces.end0.useDHCP = true;
  #   # interfaces.wlan0.useDHCP = true;
  #
  #   # Uncomment if you need wireless configuration
  #   # wireless = {
  #   #   enable = true;
  #   #   userControlled.enable = true;
  #   #   secretsFile = config.sops.secrets.wireless_secrets.path;
  #   #   networks = {
  #   #     "Haemanthus" = {
  #   #       priority = 90;
  #   #       pskRaw = "ext:haemanthus_psk";
  #   #     };
  #   #   };
  #   # };
  #
  #   # Firewall settings
  #   firewall = {
  #     enable = true;
  #     allowedTCPPorts = [
  #       22 # SSH
  #       80 # HTTP
  #       443 # HTTPS
  #       6443 # k3s: Kubernetes API server
  #       10250 # Kubelet API
  #     ];
  #     allowedUDPPorts = [
  #       # Uncomment if using Flannel in multi-node setup
  #       # 8472
  #     ];
  #   };
  # };

  # # User configuration
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

  # # SOPS secrets management
  # sops = {
  #   defaultSopsFile = "${self}/secrets/default.yaml";
  #   secrets.wireless_secrets = { };
  # };

  # Trusted public keys for Nix builds
  nix.settings.trusted-public-keys = [
    "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
  ];

}
