{
  self,
  lib,
  pkgs,
  config,
  home-manager,
  user,
  keys,
  inputs,
  ...
}:
{

  local.dock = {
    enable = true;
    entries = [
      # Development tools
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "/Applications/Firefox.app/"; }
      { path = "/Applications/Obsidian.app/"; }
      { path = "/Applications/Mendeley Reference Manager.app/"; }
      {
        path = "${config.users.users.${user}.home}/Projects";
        section = "others";
        options = "--view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--view fan --display stack";
      }
      {
        path = "${pkgs.writeShellScriptBin "update-system" ''
          ${pkgs.alacritty}/bin/alacritty -e bash -c 'cd ~/.dotfiles && nix flake update && nix run ".#switch"'
        ''}/bin/update-system";
        section = "others";
      }
    ];

    #      { path = "${pkgs.docker}/Applications/Docker.app/"; }
    #
    #      # Browsers
    #      { path = "/Applications/Google Chrome.app/"; }
    #
    #      # Communication
    #      { path = "/System/Applications/Messages.app/"; }
    #      { path = "/Applications/Zoom.app/"; }
    #
    #      # Productivity
    #      { path = "/System/Applications/Reminders.app/"; }
    #
    #      # Utils
    #      { path = "/Applications/1Password.app/"; }
    #      { path = "/Applications/TablePlus.app/"; }
    #
  };

  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [
      inputs.nixvim.homeManagerModules.nixvim
      inputs.sops-nix.homeManagerModules.sops
      ../../packages/shared/shell-aliases
    ];
    users.${user} =
      {
        self,
        config,
        pkgs,
        inputs,
        ...
      }:
      {
        imports = [
          ../shared/aliases.nix
          ../shared/secrets.nix
          ../shared/programs
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages { };
          stateVersion = "23.11";

          # https://github.com/NixOS/nixpkgs/issues/206242
          # https://github.com/nix-community/home-manager/issues/3482
          #          sessionVariables = {
          #            LIBRARY_PATH =
          #              lib.makeLibraryPath [
          #                pkgs.libiconv
          #                pkgs.iconv
          #              ]
          #              + ''${config.environment.sessionVariables.LIBRARY_PATH or ""}:$LIBRARY_PATH'';
          #          };

          #          sessionVariables = {
          #            EDITOR = "nvim";
          #            VISUAL = "nvim";
          #            PAGER = "less";
          #            LESS = "-R";
          #            LESSOPEN = "| $(which lesspipe.sh) %s";
          #            LESSCLOSE = "kill %s";
          #            LESS_TERMCAP_mb = "\e[1;31m";
          #            LESS_TERMCAP_md = "\e[1;31m";
          #            LESS_TERMCAP_me = "\e[0m";
          #            LESS_TERMCAP_se = "\e[0m";
          #            LESS_TERMCAP_so = "\e[1;44;33m";
          #            LESS_TERMCAP_ue = "\e[0m";
          #            LESS_TERMCAP_us = "\e[1;32m";
          #          };
          #                    sessionPath = [
          #                        "$HOME/.cargo/bin"
          #                          "$HOME/.local/bin"
          #                      ];
        };
      };
    extraSpecialArgs = {
      inherit user inputs self;
    };
  };

  # User configuration
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = keys;
  };

  # Homebrew configuration
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { } ++ [
      "nikitabobko/tap/aerospace"
    ];
    brews = [
      "nushell"
      "pinentry-mac"
      "qemu"
      "gsmartcontrol"
    ];
    masApps = {
      "tailscale" = 1475387142;
    };
  };
}
