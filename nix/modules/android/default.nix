{
  config,
  lib,
  pkgs,
  services,
  ...
}:

{
  imports = [
    ./ssh.nix
    # ./storage.nix
    # ./battery.nix
    # ./font.nix
  ];

  # System Configuration
  system.stateVersion = "24.05";

  # Nix Configuration
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # package = pkgs.nix;
    # nixPath = [ ];
    # registry = { };
    # substituters = [ ];
    # trustedPublicKeys = [ ];
  };

  # Nixpkgs Configuration
  # nixpkgs.config = { };
  # nixpkgs.overlays = [ ];

  # User Configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Environment Configuration
  environment = {
    packages =
      with pkgs;
      [
        git
        openssh
        # procps
        # killall
        # diffutils
        # findutils
        # utillinux
        # tzdata
        # hostname
        # man
        # gnugrep
        # gnupg
        # gnused
        # gnutar
        # bzip2
        # gzip
        # xz
        # zip
        # unzip
      ]
      ++ pkgs.callPackage ./packages.nix { inherit pkgs; };

    etcBackupExtension = ".bak";

    # etc = {
    #   "example-configuration-file" = {
    #     source = "/nix/store/.../etc/dir/file.conf.example";
    #   };
    #   "default/useradd".text = "GROUP=100 ...";
    # };

    sessionVariables = {
      EDITOR = "nvim";
      LANG = "en_US.UTF-8";
      PATH = "$HOME/.local/bin:$PATH";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
    };

    motd = ''
      echo "Welcome to Nix-on-Droid!" | lolcat
      fortune | lolcat
    '';
  };

  # Service Configuration
  services.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXHjv1eLnnOF31FhCTAC/7LG7hSyyILzx/+ZgbvFhl7"
    ];
    aliases = {
      sshd-start = "sshd-start";
      sshd-stop = "pkill sshd";
      sshd-restart = "sshd-stop && sshd-start";
      ssh-keygen = "ssh-keygen -t ed25519";
    };
  };

  # services.storage = {
  #   enable = true;
  #   showInfoOnStartup = true;
  #   aliases = {
  #     storage-info = "storage-info";
  #     storage-usage = "du -h -d 2 /sdcard | sort -h";
  #   };
  # };

  # services.battery = {
  #   enable = true;
  #   showInfoOnStartup = true;
  #   aliases = {
  #     battery-info = "battery-info";
  #     battery-saver = "am start -a android.settings.BATTERY_SAVER_SETTINGS";
  #     battery-full = "termux-notification -t 'Battery Full' -c 'Your battery is fully charged'";
  #   };
  # };

  # Terminal Configuration
  terminal = {
    font = "${
      pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }
    }/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFontMono-Regular.ttf";
    colors = {
      background = "#0F111A";
      foreground = "#8F93A2";
      cursor = "#84ffff";
      color0 = "#090B10";
      color1 = "#f07178";
      color2 = "#c3e88d";
      color3 = "#ffcb6b";
      color4 = "#82aaff";
      color5 = "#c792ea";
      color6 = "#89ddff";
      color7 = "#eeffff";
      color8 = "#464B5D";
      color9 = "#ff5370";
      color10 = "#c3e88d";
      color11 = "#f78c6c";
      color12 = "#80cbc4";
      color13 = "#c792ea";
      color14 = "#89ddff";
      color15 = "#ffffff";
    };
  };

  # Networking Configuration
  # networking = {
  #   hostName = "nix-on-droid";
  #   extraHosts = ''
  #     192.168.68.1 router.haemanthus.local
  #   '';
  #   # hosts = {
  #   #   "192.168.0.2" = [ "nas.local" ];
  #   # };
  # };

  # Android Integration
  # android-integration = {
  #   am.enable = false;
  #   termux-open.enable = false;
  #   termux-open-url.enable = false;
  #   termux-reload-settings.enable = false;
  #   termux-setup-storage.enable = false;
  #   termux-wake-lock.enable = false;
  #   termux-wake-unlock.enable = false;
  #   unsupported.enable = false;
  #   xdg-open.enable = false;
  # };

  # Home Manager Configuration
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit (config) services;
    };
    config =
      {
        config,
        lib,
        pkgs,
        inputs,
        services,
        ...
      }:
      {
        home.stateVersion = "24.05";
        system.os = "android";
        imports = [
          ../shared/home-manager/programs/git.nix
          ../shared/home-manager/programs/gh.nix
          ../shared/home-manager/programs/htop.nix
          ../shared/home-manager/programs/nushell.nix
          ../shared/home-manager/programs/nvim.nix
          ../shared/home-manager/programs/starship.nix
          ../shared/home-manager/programs/zellij.nix
          ../shared/home-manager/programs/zsh.nix
          ./secrets.nix
        ];

        programs.bash = {
          enable = true;
          shellAliases =
            let
              sshAliases = if services.ssh.enable then services.ssh.aliases else { };
            in
            # storageAliases = if services.storage.enable then services.storage.aliases else {};
            # batteryAliases = if services.battery.enable then services.battery.aliases else {};
            {
              ll = "ls -l";
              hw = "echo 'Hello, World!'";
              switch = "nix-on-droid switch --flake ~/.dotfiles";
            }
            // sshAliases;
          # // storageAliases
          # // batteryAliases;
        };

        home.packages = with pkgs; [
          fortune
          lolcat
        ];
      };
  };

  # Build Configuration
  # build = {
  #   activation = { };
  #   activationBefore = { };
  #   activationAfter = { };
  # };
}
