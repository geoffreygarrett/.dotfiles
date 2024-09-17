{ config, pkgs, ... }:

let
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Uy9fE/YF8/puhUOwOcHKqDzDW75zt9DndypPEhQaG nix-on-droid@localhost" 
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITvBraRmM6IvQFt8VUHRx9hZ5DZVkPX3ORlfVqGa05z" ];
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

  # File systems configuration
  fileSystems."/boot/efi" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nofail" ];
  };

  # Networking
  networking = {
    hostName = "apollo";
    networkmanager.enable = true;
    interfaces = {
      enp3s0.wakeOnLan.enable = true;
      tailscale0.wakeOnLan.enable = true;
    };
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
      trustedInterfaces = [ "tailscale0" "enp3s0" ];
      allowedUDPPortRanges = [{ from = 41641; to = 41641; }];
      # extraCommands = ''
      #   iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
      #   iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
      # '';  # Example: rate limiting for SSH connections
    };
  };

  # Services
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both"; # Enable subnet routing and exit nodes
    };
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        #sessionCommands = ''
        #  ${pkgs.xorg.xset}/bin/xset r rate 225 30
        #  ${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout us -option ctrl:nocaps
        #  ${pkgs.xorg.xset}/bin/xset b off  # Disable terminal bell
        #'';
      };
      #autoRepeatDelay = 225;
      #autoRepeatInterval = 30;
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
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  # Tailscale autoconnect service
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
    wants = [ "network-pre.target" "tailscale.service" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      set -euo pipefail
      echo "Starting Tailscale autoconnect service"
      sleep 2
      echo "Checking Tailscale status"
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        echo "Tailscale is already running"
        exit 0
      fi
      echo "Authenticating to Tailscale"
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
      extraRules = [{
        commands = [{
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }];
        groups = [ "wheel" ];
      }];
    };
  };

  # User configuration
  users.users = {
    geoffrey = {
      isNormalUser = true;
      description = "Geoffrey Garrett";
      extraGroups = [ "networkmanager" "wheel" "docker" "tailscale" ];
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

  # Programs
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
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Uncomment to allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # Additional Tailscale configuration (commented out)
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
}

