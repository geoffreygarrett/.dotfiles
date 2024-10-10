{
  config,
  pkgs,
  inputs,
  keys,
  ...
}:

let
  hostname = "curiosity";
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    inputs.jetpack-nixos.nixosModules.default
    # inputs.sops-nix.nixosModules.default
    ../shared.nix
    # ./llama2.nix # Import the new Llama 2 module
  ];

  # System configuration
  system.stateVersion = "24.11";
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.openssh.enable = true;

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.enable = false;
  };

  # Hardware configuration
  hardware = {
    graphics.enable = true;
    nvidia = {
      package = nvidiaPackage;
      open = false;
      modesetting.enable = true;
    };
    nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      carrierBoard = "devkit";
    };
  };

  # Networking configuration
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        8080
      ]; # SSH and Llama 2 API port
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    tmux
    usbutils
  ];

  # Security configuration
  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  # Nix configuration
  nix = {
    settings = {
      trusted-users = [
        "root"
        "geoffrey"
      ];
      trusted-public-keys = [
        "builder-name:4w+NIGfO0WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # SSH configuration
  users.users = {
    root.openssh.authorizedKeys.keys = keys;
    geoffrey = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Docker configuration (optional, for container-based deployment)
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Power management
  powerManagement.cpuFreqGovernor = "ondemand";

  # System optimization
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # Automatic updates (optional)
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = "https://nixos.org/channels/nixos-unstable";
  };
}
