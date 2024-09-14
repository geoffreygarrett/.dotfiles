{
  self,
  lib,
  pkgs,
  home-manager,
  user,
  inputs,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [
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
          ../shared/home-manager/programs
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages/user.nix { };
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
  };

  # Homebrew configuration
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
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
