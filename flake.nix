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
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      utils = import ./nix/utils.nix { inherit nixpkgs home-manager; };
      localPkgs = import ./nix/nixpkgs { inherit nixpkgs; };
    in
    {

      homeConfigurations = {
        "geoffrey@apollo" = utils.mkHomeConfiguration {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "apollo";
        };

        "geoffreygarrett@geoffreys-macbook-air" = utils.mkHomeConfiguration {
          system = "aarch64-darwin";
          username = "geoffreygarrett";
          hostname = "geoffreys-macbook-air";
          extraModules = [
            ({ pkgs, ... }:
              let
                localPkgs = import ./nix/nixpkgs {
                  inherit (pkgs) lib stdenv stdenvNoCC fetchurl unzip;
                };
              in
              {
                home.packages = [
                  localPkgs.hammerspoon
                ];
              })
          ];
        };
      };

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
    };
}
