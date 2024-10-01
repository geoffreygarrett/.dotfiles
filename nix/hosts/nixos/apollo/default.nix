{
  user,
  pkgs,
  inputs,
  keys,
  lib,
  ...
}:
let
  hostname = "apollo";
  mainInterface = "eno2";
  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };
in
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.autorandr = {
    enable = true;
    defaultTarget = "dual-monitor";
    profiles = {
      "dual-monitor" = {
        fingerprint = builtins.fromJSON (builtins.readFile ./config/fingerprint.json);
        config = {
          "HDMI-1" = {
            enable = true;
            mode = "3840x2160";
            rate = "59.94";
            primary = false;
            position = "0x0";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
          "DP-4" = {
            enable = true;
            mode = "2560x1440";
            rate = "143.97";
            primary = true;
            position = "3840x720";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
        };
      };
    };
    hooks = {
      postswitch = {
        "notify-polybar" = toString (
          pkgs.writeShellScript "notify-polybar" ''
            ${pkgs.systemd}/bin/systemctl --user restart polybar
          ''
        );
        "notify-bspwm" = toString (
          pkgs.writeShellScript "notify-bspwm" ''
            sleep 2
            ${pkgs.bspwm}/bin/bspc monitor HDMI-1 -d 4 5 6
            ${pkgs.bspwm}/bin/bspc monitor DP-4 -d 1 2 3
            #${pkgs.bspwm}/bin/bspc wm -r
          ''
        );
      };
    };
  };

  hardware.graphics.enable32Bit = true; # Needed for enableNvidia
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true; # Deprecated for below.
  };
  hardware.nvidia-container-toolkit.enable = true;

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
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixus.nixosModules.spotify
    ../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/openssh.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
    ../../../modules/nixos/key-repeat.nix
    ../mariner/k3/agent.nix
    ./k3s.nix
    ../shared.nix
    ./config/desktop.nix
    ../../../scripts/network-tools.nix
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

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  hardware.nvidia.open = false; # Disable open source

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
    sopss
  ];

  home-manager.users.${user} = {
    # home.activation.generateSopsAgeKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/sops/age
    #   if [[ ! -f ~/.config/sops/age/keys.txt ]]; then
    #     $DRY_RUN_CMD ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
    #     $DRY_RUN_CMD chmod 600 ~/.config/sops/age/keys.txt
    #   fi
    # '';
    home.packages = with pkgs; [
      # Applications
      # "firefox"
      # "spotify"
      # "vlc"
      # "code"
      # "steam"
      # "discord"
      # "signal-desktop"
      # "slack"
      # "zoom"
      # "obs-studio"
      # "kdenlive"
      # "gimp"
      # "inkscape"
      # "krita"
      # "blender"
      # "darktable"
      # "rawtherapee
      # minecraft
      prismlauncher
    ];
  };
  nix.settings.trusted-users = [
    "root"
    "geoffrey"
  ];

  boot.loader = {
    systemd-boot.enable = false;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
      gfxmodeEfi = "2560x1440";
      theme = "${hyperfluent-theme}/nixos";
      extraConfig = ''
        GRUB_DEFAULT=saved
        GRUB_SAVEDEFAULT=true
      '';
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
        # 4070 # Spotify: General communication port
        # 57621 # Spotify: Sync local tracks with mobile devices on the same network
      ];
    };
  };

}
