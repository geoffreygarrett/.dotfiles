{
  config,
  pkgs,
  inputs,
  keys,
  ...
}:

let
  hostname = "curiosity";
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    inputs.jetpack-nixos.nixosModules.default
    ../../../users/geoffrey/nixos/server.nix
    # inputs.sops-nix.nixosModules.default
    ../shared.nix
    # ./llama2.nix # Import the new Llama 2 module
  ];

  # hardware.nvidia.modesetting.enable = true;
  # hardware.graphics.enable = true;
  # boot.kernelParams = [
  #   "nvidia_drm.modeset=1" # Required for modesetting
  #   "nvidia_drm.fbdev=1" # Optional, may help with framebuffer issues
  # ];

  # boot.initrd.kernelModules = [
  #   "nvidia"
  #   "nvidia_modeset"
  #   "nvidia_uvm"
  #   "nvidia_drm"
  # ];
  #
  services.xserver = {
    enable = true;
    #   displayManager = {
    #     lightdm.enable = true;
    #     defaultSession = "none+i3"; # Changed from "gnome" to "i3"
    #   };
    #   # desktopManager.gnome.enable = false;
    #   windowManager.i3 = {
    #     enable = true;
    #     # package = pkgs.i3-gaps; # Use i3-gaps instead of regular i3
    #   };
    #   # videoDrivers = [ "nvidia" ];
  };
  # services.xserver.displayManager.gdm.enable = false;

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
    # nvidia = {
    #   # package = config.boot.kernelPackages.nvidiaPackages.stable;
    #   open = false;
    #   # modesetting.enable = false;
    #   nvidiaSettings = true;
    # };
    nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      carrierBoard = "devkit";
      modesetting.enable = false;
    };
  };

  # Networking configuration
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    tmux
    usbutils
    nvtop
  ];

  # Security configuration
  security.sudo.wheelNeedsPassword = false;

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
  users.users.root.openssh.authorizedKeys.keys = keys;
}
