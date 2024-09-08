{ inputs, config, lib, pkgs, ... }:

{
  # Packages to be installed
  environment.packages = with pkgs; [
    neovim
    git
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # Uncomment the packages you want to install
    #procps
    #killall
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];

  # Backup extension for /etc files
  environment.etcBackupExtension = ".bak";

  # Extra /etc files to install
  # environment.etc = {
  #   "example-configuration-file" = {
  #     source = "/nix/store/.../etc/dir/file.conf.example";
  #   };
  #   "default/useradd".text = "GROUP=100 ...";
  # };

  # Environment variables
  # environment.sessionVariables = {
  #   EDITOR = "vim";
  # };

  # Text to show on every new shell
  # environment.motd = ''
  #   Welcome to Nix-on-Droid!
  # '';

  # Extra options passed to proot
  # build.extraProotOptions = [ ];

  # State version (read the changelog before changing)
  system.stateVersion = "24.05";

  # Nix configuration
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

  # Nixpkgs configuration
  # nixpkgs.config = { };
  # nixpkgs.overlays = [ ];

  # Set your time zone
  # time.timeZone = "Europe/Berlin";

  # User configuration
  # user = {
  #   shell = "${pkgs.bashInteractive}/bin/bash";
  #   # uid = 1000;  # Do not change unless you know what you're doing
  #   # gid = 1000;  # Do not change unless you know what you're doing
  # };

  # Networking configuration
  # networking = {
  #   hostName = "nix-on-droid";
  #   extraHosts = ''
  #     192.168.0.1 router.local
  #   '';
  #   # hosts = {
  #   #   "192.168.0.2" = [ "nas.local" ];
  #   # };
  # };

  # Terminal configuration
  # terminal = {
  #   font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
  #   colors = {
  #     background = "#000000";
  #     foreground = "#FFFFFF";
  #     cursor = "#FFFFFF";
  #     # color0 to color15 can be defined here
  #   };
  # };

  terminal.font = "${pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFontMono-Regular.ttf";
  #    font = "${pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFontMono-Regular.ttf";
  terminal.colors = {
    # Main colors
    background = "#0F111A";
    foreground = "#8F93A2";
    cursor = "#84ffff"; # Accent Color

    # Basic colors
    color0 = "#090B10"; # Black (Contrast)
    color1 = "#f07178"; # Red
    color2 = "#c3e88d"; # Green
    color3 = "#ffcb6b"; # Yellow
    color4 = "#82aaff"; # Blue
    color5 = "#c792ea"; # Purple
    color6 = "#89ddff"; # Cyan
    color7 = "#eeffff"; # White

    # Bright colors
    color8 = "#464B5D"; # Bright Black (Disabled)
    color9 = "#ff5370"; # Bright Red (Error Color)
    color10 = "#c3e88d"; # Bright Green (same as Green)
    color11 = "#f78c6c"; # Bright Yellow (Orange)
    color12 = "#80cbc4"; # Bright Blue (Links Color)
    color13 = "#c792ea"; # Bright Purple (same as Purple)
    color14 = "#89ddff"; # Bright Cyan (same as Cyan)
    color15 = "#ffffff"; # Bright White (Selection Foreground)
  };

  # Android integration
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

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    # useUserPackages = false;
    # extraSpecialArgs = { };
    # sharedModules = [ ];

    config =
      { config, lib, pkgs, ... }:
      {
        # Read the changelog before changing this value
        home.stateVersion = "24.05";

        extraSpecialArgs = { inherit inputs; };

        imports = [
          #          ../shared/home-manager/programs
          # Uncomment the modules you want to import
          # ../shared/home-manager/programs/git.nix
          ../shared/home-manager/programs/nushell.nix
          #           ../shared/home-manager/programs/nvim.nix
          ../shared/home-manager/programs/starship.nix
          ../shared/home-manager/programs/zellij.nix
          ../shared/home-manager/programs/zsh.nix
        ];

        # Your home-manager configuration goes here
        programs = {
          bash = {
            enable = true;
            shellAliases = {
              ll = "ls -l";
              hw = "echo 'Hello, World!'";
              switch = "nix-on-droid switch --flake ~/.dotfiles";
            };
          };
        };


        home.packages = with pkgs; [
          htop
          fortune
        ];
      };
    #      // import ../shared/home-manager/programs/git.nix { inherit inputs config pkgs lib; }
    #      // import ../shared/home-manager/programs/nushell.nix { inherit inputs config pkgs lib; }
    #      #      // import ../shared/home-manager/programs/nvim.nix { inherit inputs config pkgs lib; }
    #      // import ../shared/home-manager/programs/starship.nix { inherit inputs config pkgs lib; }
    #      // import ../shared/home-manager/programs/zellij.nix { inherit inputs config pkgs lib; }
    #      // import ../shared/home-manager/programs/zsh.nix { inherit inputs config pkgs lib; };
  };

  # Build configuration
  # build = {
  #   activation = { };
  #   activationBefore = { };
  #   activationAfter = { };
  # };
}
