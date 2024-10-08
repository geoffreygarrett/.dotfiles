{
  lib,
  pkgs,
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
    inputs.argon40-nix.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
    # ./kubernetes.nix
    ../../../../modules/shared/secrets.nix
    ../../../../modules/nixos/tailscale.nix
    ../../../../modules/nixos/openssh.nix
    # ../../../../modules/nixos/samba.nix
    ../../../../scripts/network-tools.nix
    ../k3/server.nix
    ./disko-ext4.nix
    inputs.disko.nixosModules.disko
    ../../../../users/geoffrey/nixos/server.nix
    ../../shared.nix
    # ./argon-ir.nix

  ];

  # Enable the Argon IR service
  # services.argonIR = {
  #   enable = true;
  #   # Optionally, you can customize these:
  #   gpioPin = 23; # Default is 23
  #   user = "geoffrey"; # Default is "1000"
  # };
  #
  services.networkTools.enable = true;

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

  # Argon one case
  programs.argon.one = {
    enable = true;

    settings = {
      # Is 'celsius' by default, can also be set to 'fahrenheit'
      displayUnits = "celsius";

      # This is the same config as the original Argon40 config.
      # This is also the default config for this flake.
      fanspeed = [
        {
          # This the temperature threshold at which this fan speed will activate.
          # The temperature is in the above specified unit.
          temperature = 55;
          # This is speed percentage at which the fan will spin.
          speed = 30;
        }
        {
          temperature = 60;
          speed = 55;
        }
        {
          temperature = 65;
          speed = 100;
        }
      ];
    };
  };

  # Kernel Modules and Power Management
  boot.initrd.availableKernelModules = [
    # Raspberry Pi-specific modules
    "vc4"
    "bcm2835_dma"
    "i2c_bcm2835"

    # SSD boot support
    # "usb_storage"
    # "xhci_pci"
    # "usbhid"
    "uas"
  ];

  # boot.blacklistedKernelModules = [
  #   "brcmfmac"
  #   "brcmutil"
  # ];

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

  # boot.kernelParams = [
  #   "console=ttyS0,115200n8"
  #   "console=tty0"
  # ];

  # Filesystem and kernel options
  # boot.supportedFilesystems = [
  #   "ext4"
  #   "btrfs"
  #   "vfat"
  # ];

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Networking and Services
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Network and firewall configurationa
  networking.networkmanager.enable = true;
  networking.hostName = hostname;
  # networking = {
  #   hostName = hostname;
  #   useDHCP = false;
  #   dhcpcd.wait = "background";
  #   interfaces.wlan0.useDHCP = true;
  #   interfaces.enabcm6e4ei0.useDHCP = true;
  #   wireless = {
  #     enable = true;
  #     userControlled.enable = true;
  #     secretsFile = config.sops.secrets.wireless_secrets.path;
  #     networks = {
  #       "Haemanthus" = {
  #         priority = 90;
  #         pskRaw = "ext:haemanthus_psk";
  #       };
  #     };
  #   };
  #
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
  #       # 8472  # Required if using Flannel in multi-node setup
  #     ];
  #   };
  # };

  # networking.usePredictableInterfaceNames = false;
  # networking = {
  #   hostName = hostname;
  #   useDHCP = false;
  #   interfaces.enabcm6e4ei0 = {
  #     useDHCP = true;
  #   };
  #   interfaces.eth0 = {
  #     useDHCP = true;
  #   };
  # };

  # # User configuration
  # users.users.${user} = {
  #   isNormalUser = true;
  #   shell = pkgs.zsh;
  #   extraGroups = [
  #     "wheel"
  #     "networkmanager"
  #   ];
  #   initialPassword = "changeme";
  #   openssh.authorizedKeys.keys = keys;
  # };

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
  home-manager.extraSpecialArgs = {
    inherit inputs user;
  };
  # # Home Manager configuration
  # home-manager.users = lib.genAttrs [ "${user}" ] (
  #   username:
  #   { lib, config, ... }:
  #   {
  #     home.stateVersion = "24.11";
  #     imports = [
  #       ../../../../modules/shared/programs/gh.nix
  #       ../../../../modules/shared/programs/git.nix
  #       ../../../../modules/shared/programs/tms.nix
  #       ../../../../modules/shared/programs/starship.nix
  #       ../../../../modules/shared/programs/nushell.nix
  #       ../../../../modules/shared/programs/zsh.nix
  #     ];
  #     programs = {
  #       neovim = {
  #         enable = true;
  #       };
  #       ssh = {
  #         enable = true;
  #
  #         matchBlocks = {
  #           "*" = {
  #             identityFile = "~/.ssh/id_ed25519";
  #             extraOptions = {
  #               AddKeysToAgent = "yes";
  #             };
  #           };
  #         };
  #
  #         extraConfig = ''
  #           Host github.com
  #             IdentitiesOnly yes
  #             IdentityFile ~/.ssh/github_ed25519
  #         '';
  #       };
  #     };
  #

  # );

}
