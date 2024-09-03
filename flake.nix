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
    nixgl = {
        url = "github:nix-community/nixGL";
        inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixgl, ... }@inputs:
    let
     pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nixgl.overlay ];
          };
      utils = import ./nix/utils.nix { inherit nixpkgs home-manager; };
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
        };
      };

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
    };
}
