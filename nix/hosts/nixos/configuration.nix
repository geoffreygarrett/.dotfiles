{ config, pkgs, ... }:

let
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITvBraRmM6IvQFt8VUHRx9hZ5DZVkPX3ORlfVqGa05z" ];
  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  # System-wide configurations
  system.stateVersion = "24.05";
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = false; # Disable systemd-boot
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      #useOSProber = true;
      gfxmodeEfi = "2560x1440";
      theme = "${hyperfluent-theme}/nixos";
      extraConfig = ''
        GRUB_DEFAULT=saved
        GRUB_SAVEDEFAULT=true
      '';
    };
  };

  # File systems configuration
  fileSystems."/boot/efi" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = [
      "defaults"
      "noatime"
      "nofail"
    ];
  };

  # Networking
  networking = {
    hostName = "apollo";
    networkmanager.enable = true;
    # wireless.enable = true;  # Uncomment to enable wireless support via wpa_supplicant
    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [
        53 # DNS
        41641 # Tailscale
      ];
      # Tailscale-specific firewall rules
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPortRanges = [
        {
          from = 41641;
          to = 41641;
        }
      ];
      # extraCommands = ''
      #   iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
      #   iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
      # '';  # Example: rate limiting for SSH connections
    };
    # Tailscale configuration
    #    tailscale.enable = true;
  };

  # Services
  services = {
    tailscale = {
      enable = true;
      openFirewall = true; # This replaces the manual firewall configuration
      useRoutingFeatures = "both"; # Enable subnet routing and exit nodes
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      # libinput.enable = true;  # Uncomment to enable touchpad support
      # videoDrivers = [ "nvidia" ];  # Uncomment for NVIDIA support
    };
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # jack.enable = true;  # Uncomment to enable JACK support
    };
    hardware.openrgb.enable = true;
    # openssh.enable = true;  # Uncomment to enable OpenSSH server
  };

  # Enable OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # create aoneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
    wants = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      set -euo pipefail
      echo "Starting Tailscale autoconnect service"
      # wait for tailscaled to settle
      sleep 2
      echo "Checking Tailscale status"
      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        echo "Tailscale is already running"
        exit 0
      fi
      echo "Authenticating to Tailscale"
      # otherwise authenticate with tailscale
      if [ ! -f "${config.sops.secrets.tailscale-auth-key.path}" ]; then
        echo "Error: Tailscale auth key file not found"
        exit 1
      fi
      ${tailscale}/bin/tailscale up -authkey "$(cat ${config.sops.secrets.tailscale-auth-key.path})"
      echo "Tailscale authentication completed"
    '';
  };
  # Security
  security = {
    rtkit.enable = true;
    sudo = {
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
  };

  # User configuration
  users.users = {
    geoffrey = {
      isNormalUser = true;
      description = "Geoffrey Garrett";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "tailscale" # Add the tailscale group
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
      packages = with pkgs; [
        # thunderbird
      ];
    };
    root.openssh.authorizedKeys.keys = keys;
  };

  # System packages and programs
  environment.systemPackages = with pkgs; [
    tailscale
    openrgb-with-all-plugins
    gitAndTools.gitFull
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
    (writeScriptBin "reboot-to-windows" ''
      #!${pkgs.stdenv.shell}
      windows_menu_entry=$(grep menuentry /boot/grub/grub.cfg | grep -i windows | cut -d "'" -f2)
      sudo grub-reboot "$windows_menu_entry" && sudo reboot
    '')
    # vim
    # wget
  ];

  # # Systemd configuration for Tailscale
  # systemd.services.tailscaled = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [
  #     "network-pre.target"
  #     "NetworkManager.service"
  #     "systemd-resolved.service"
  #   ];
  #   wants = [
  #     "network-pre.target"
  #     "NetworkManager.service"
  #     "systemd-resolved.service"
  #   ];
  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #   };
  # };

  # Uncomment to allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # mtr.enable = true;
  };

  # Font configuration
  fonts.packages = with pkgs; [
    roboto
    dejavu_fonts
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Hardware configuration
  hardware = {
    pulseaudio.enable = false;
    # opengl = {
    #   enable = true;
    #   driSupport = true;
    #   driSupport32Bit = true;
    # };
    # nvidia = {
    #   modesetting.enable = true;
    #   powerManagement.enable = true;
    #   open = false;
    #   nvidiaSettings = true;
    #   package = config.boot.kernelPackages.nvidiaPackages.stable;
    # };
  };

  # Virtualization
  # virtualisation = {
  #   docker.enable = true;
  #   libvirtd.enable = true;
  # };

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
