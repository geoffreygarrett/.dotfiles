{
  config,
  lib,
  pkgs,
  inputs,
  keys,
  ...
}:

let
  mainDriveUuid = "41c98998-6a08-4389-bf74-79c9efcf0739";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.argon40-nix.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  # # Disko configuration for SSD
  # disko.devices = {
  #   disk = {
  #     main = {
  #       device = "/dev/disk/by-uuid/${mainDriveUuid}";
  #       type = "disk";
  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           boot = {
  #             name = "boot";
  #             size = "256M";
  #             type = "EF00";
  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #             };
  #           };
  #           root = {
  #             name = "root";
  #             size = "100%";
  #             content = {
  #               type = "filesystem";
  #               format = "ext4";
  #               mountpoint = "/nix";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
  #
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=2G"
        "mode=755"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/${mainDriveUuid}";
      fsType = "ext4";
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-uuid/0F92-BECC"; # Use this UUID, but adjust to your preferred definition
      fsType = "vfat";
    };
  };

  # Boot loader configuration for Raspberry Pi 4
  # boot.loader = {
  #   grub.enable = false;
  #   generic-extlinux-compatible.enable = true;
  #   raspberryPi = {
  #     enable = true;
  #     version = 4;
  #   };
  # };

  # # Impermanence configuration
  # environment.persistence."/nix/persist" = {
  #   hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/nixos"
  #     "/var/lib/systemd"
  #     "/etc/nixos"
  #     "/var/lib/kubernetes"
  #     "/home"
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #   ];
  # };

  # Networking
  networking = {
    hostName = "rpi4-nixos";
    useDHCP = false;
    dhcpcd.wait = "background";
    interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
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
        22
        80
        443
        6443
        10250
      ];
    };
  };

  # User configuration
  users = {
    mutableUsers = false;
    users = {
      root = {
        initialPassword = "changeme";
      };
      geoffrey = {
        isNormalUser = true;
        home = "/home/geoffrey";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        initialPassword = "changeme";
        openssh.authorizedKeys.keys = keys;
      };
    };
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Additional system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    tmux
  ];

  # Nix settings
  nix.settings = {
    trusted-public-keys = [
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # SOPS configuration
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/default.yaml";
    secrets = {
      wireless_secrets = { };
      "users/geoffrey/password" = { };
    };
  };

  # System state version
  system.stateVersion = "24.11";

  # Additional configurations
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Enable Raspberry Pi hardware support
  hardware.enableRedistributableFirmware = true;

  # Time zone and locale settings
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Tailscale
  services.tailscale.enable = true;

  # Home Manager configuration
  home-manager.users.geoffrey =
    { pkgs, ... }:
    {
      home.stateVersion = "24.11";
    };
}
