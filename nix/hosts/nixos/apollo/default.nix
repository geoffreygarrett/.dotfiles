{
  user,
  pkgs,
  inputs,
  keys,
  config,
  ...
}:
let
  hostname = "apollo";
  mainInterface = "eno2";
in
{

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };
  # nixpkgs.config.allowUnfree = lib.mkForce true;
  boot.kernelParams = [
    "video=DP-4:2560x1440@143.97"
    "video=DP-0:d"
    "nvidia-drm.modeset=1"
    "nvidia.modeset=1"
  ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  environment.sessionVariables = {
    #   LD_LIBRARY_PATH = [ "/ruopengl-driver/lib" ];
    #   "LIBGL_ALWAYS_SOFTWARE" = "0";
    "LIBGL_DEBUG" = "verbose";
  };
  # services.xserver.displayManager.setupCommands = ''
  #   ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --primary
  # '';
  #
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true; # Deprecated for below.
  };
  hardware.nvidia-container-toolkit.enable = true;
  home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # systemd.services.autorandr = {
  #   wantedBy = [ "graphical-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   # after = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.autorandr}/bin/autorandr --change --default default";
  #   };
  # };
  imports = [
    # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
    # Intel(R) Core(TM) i9-9900KS (16) @ 5.00 GHz
    # NVIDIA GeForce GTX 1080 Ti [Discrete]
    ./hardware-configuration.nix
    # inputs.nixos-hardware.nixosModules.common-pc
    # inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
    # inputs.nixos-hardware.nixosModules.common-gpu-intel
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    # inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixus.nixosModules.spotify
    ../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/openssh.nix
    ../../../modules/nixos/tailscale.nix
    # ../../../modules/nixos/samba.nix
    ../mariner/k3/agent.nix
    ./k3s.nix
    ../shared.nix
    ./config/desktop.nix
    ../../../users/geoffrey/nixos/desktop.nix
    ../../../scripts/network-tools.nix
    ./modules/autorandr.nix
  ];

  services.networkTools.enable = true;
  system.stateVersion = "24.11";
  nix.settings.secret-key-files = "/etc/nix/cache-priv-key.pem";

  # Nixus: my personal configuration module wrappers.
  nixus.spotify = {
    enable = true;
    useNerdFonts = true;
    firewall = {
      enableLocalDiscovery = true;
      enableLocalSync = true;
      enableSpotifyConnect = true;
      acknowledgeFirewallRisks = true;
    };
  };

  # FIXME: Just like with Windows, 2 hours early, maybe BIOS?
  # services.automatic-timezoned.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.zsh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = keys;

  # All custom options originate from the shared options
  #custom.openrgb.enable = true;

  # boot.initrd.kernelModules = [
  #   "nvidia"
  #   "i915"
  #   "nvidia_modeset"
  #   "nvidia_uvm"
  #   "nvidia_drm"
  # ];

  systemd.services.wakeonlan = {
    description = "Reenable wake on lan every boot";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "true";
      ExecStart = "${pkgs.ethtool}/sbin/ethtool -s ${mainInterface} wol g";
    };
    wantedBy = [ "default.target" ];
  };

  environment.systemPackages = with pkgs; [
    jdk17
    sops
  ];

  nix.settings.trusted-users = [
    "root"
    "geoffrey"
  ];

  # Enable better console fonts for high-res displays
  # console.font = "latarcyrheb-sun32";
  console.earlySetup = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.timeout = 5;
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "max";
    systemd-boot.configurationLimit = 3;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = false;
      # device = "nodev";
      # efiSupport = true;
      # efiInstallAsRemovable = true;
      # useOSProber = true;
      # gfxmodeEfi = "2560x1440";
      # theme = "${hyperfluent-theme}/nixos";
      # extraConfig = ''
      #   GRUB_DEFAULT=saved
      #   GRUB_SAVEDEFAULT=true
      # '';
    };
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    interfaces."${mainInterface}".wakeOnLan.enable = true;
    useDHCP = false;
    dhcpcd.wait = "background";
    firewall = {
      # For more information on Spotify-specific configuration, visit:
      # https://nixos.wiki/wiki/Spotify
      #
      # Note: Always review and adjust firewall rules based on your specific needs and security requirements.
      # Opening ports increases potential attack surface, so only open what's necessary for your use case.
      enable = true;

      # UDP ports
      allowedUDPPorts = [
        # 5353
        # mDNS (Multicast DNS)
        # Used for local network service discovery, including:
        # - Spotify: Discovery of Google Cast and Spotify Connect devices
        # - Other services: Printer discovery, Apple Bonjour, etc.
      ];

      # TCP ports
      allowedTCPPorts = [
        22 # SSH (Secure Shell) for remote access and management
        80 # HTTP for web services
        443 # HTTPS for secure web services
        9123 # Elgato light
        # 4070 # Spotify: General communication port
        # 57621 # Spotify: Sync local tracks with mobile devices on the same network
      ];
    };
  };

}
