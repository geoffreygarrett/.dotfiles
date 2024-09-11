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
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
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
          ../shared/secrets.nix
          ../shared/home-manager/programs
        ];
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          stateVersion = "23.11";
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
    ];
    masApps = {
      "tailscale" = 1475387142;
    };
  };
}
