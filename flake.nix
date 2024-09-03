{
  description = "Cross-platform terminal setup with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "./dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }@inputs:
    let
      utils = import ./nix/utils.nix { inherit nixpkgs home-manager; };
    in
    {

      homeConfigurations = {
        "geoffrey@geoffrey-linux-pc" = utils.mkHomeConfiguration {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "geoffrey-linux-pc";
          extraModules = [
            ({ config, pkgs, lib, ... }:
              let
                dotfilesConfig = dotfiles.mkDotfilesConfig {
                  configDir = "."; # Adjust this path as needed
                  xdgConfigHome = "$HOME/.nix-config"; # This will now take precedence
                };
              in
              builtins.trace "Applying dotfiles configuration" {
                home.file = dotfilesConfig.home.file;
                home.sessionVariables = lib.mkForce dotfilesConfig.home.sessionVariables;
              })
          ];
        };

        "geoffreygarrett@geoffreys-macbook-air" = utils.mkHomeConfiguration {
          system = "aarch64-darwin";
          username = "geoffreygarrett";
          hostname = "geoffreys-macbook-air";
          extraModules = [
            ({ config, pkgs, lib, ... }:
              let
                dotfilesConfig = dotfiles.mkDotfilesConfig {
                  configDir = "."; # Adjust this path as needed
                  xdgConfigHome = "$XDG_CONFIG_HOME"; # This will now take precedence
                };
              in
              {
                home.file = dotfilesConfig.home.file;
                home.sessionVariables = lib.mkForce dotfilesConfig.home.sessionVariables;
              })
          ];
        };
      };

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
    };
}
