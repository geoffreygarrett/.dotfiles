#{
#  description = "Cross-platform terminal setup with Home Manager";
#
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    darwin = {
#      url = "github:lnl7/nix-darwin/master";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    sops-nix = {
#      url = "github:Mic92/sops-nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    pre-commit-hooks = {
#      url = "github:cachix/git-hooks.nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    nixgl = {
#      url = "github:nix-community/nixGL";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#  };
#
#  outputs = { self, nixpkgs, home-manager, pre-commit-hooks, nixgl, ... }@inputs:
#    let
#      utils = import ./nix/utils.nix { inherit nixpkgs home-manager; };
#      overlays = [ nixgl.overlay ];
#      localPkgs = import ./nix/nixpkgs { inherit nixpkgs; };
#      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
#      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
#      mkPkgs = system: import nixpkgs {
#        inherit system overlays;
#        config.allowUnfree = true;
#      };
#    in
#    {
#      homeConfigurations = {
#   "geoffrey@apollo" = utils.mkHomeConfiguration {
#            system = "x86_64-linux";
#            username = "geoffrey";
#            hostname = "apollo";
#            extraModules = [
#              ({ pkgs, ... }: {
#                home.packages = with pkgs; [
#                  mkPkgs.nixGLDefault
#                ];
#                home.file.".local/bin/alacritty-gl" = {
#                  text = ''
#                    #!/bin/sh
#                    ${mkPkgs.nixgl.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
#                  '';
#                  executable = true;
#                };
#                home.sessionVariables = {
#                  NIXGL = "${mkPkgs.nixgl.nixGLDefault}/bin/nixGL";
#                };
#              })
#            ];
#          };
#
#        "geoffreygarrett@geoffreys-macbook-air" = utils.mkHomeConfiguration {
#          system = "aarch64-darwin";
#          username = "geoffreygarrett";
#          hostname = "geoffreys-macbook-air";
#          extraModules = [
#            ({ pkgs, ... }:
#              let
#                localPkgs = import ./nix/nixpkgs {
#                  inherit (pkgs) lib stdenv stdenvNoCC fetchurl unzip;
#                };
#              in
#              {
#                home.packages = [
#                  localPkgs.hammerspoon
#                ];
#              })
#          ];
#        };
#      };
#
#      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
#        // forAllSystems (system: {
#        pre-commit-check = pre-commit-hooks.lib.${system}.run {
#          src = ./.;
#          hooks = {
#            nixpkgs-fmt.enable = true;
#          };
#        };
#      });
#
#      devShells = forAllSystems (system: {
#        default = nixpkgs.legacyPackages.${system}.mkShell {
#          inherit (self.checks.${system}.pre-commit-check) shellHook;
#          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
#        };
#      });
#    };
#}

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
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
    };
  };

  outputs = { self, nixpkgs, home-manager, pre-commit-hooks, nixgl, ... }@inputs:
    let
      utils = import ./nix/utils.nix { inherit nixpkgs home-manager; };
      overlays = [ nixgl.overlay ];
      localPkgs = import ./nix/nixpkgs { inherit nixpkgs; };
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      mkPkgs = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations = {
        "geoffrey@apollo" = utils.mkHomeConfiguration {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "apollo";
          extraModules = [
            ({ pkgs, ... }:
              let
                myPkgs = mkPkgs "x86_64-linux";
              in
              {
                home.packages = [
                  myPkgs.nixgl.auto.nixGLDefault
                ];
                home.file.".local/bin/alacritty-gl" = {
                  text = ''
                    #!/bin/sh
                    ${myPkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
                  '';
                  executable = true;
                };
                home.sessionVariables = {
                  NIXGL = "${myPkgs.nixgl.auto.nixGLDefault}/bin/nixGL";
                };
              })
          ];
        };

        "geoffreygarrett@artemis" = utils.mkHomeConfiguration {
          system = "aarch64-darwin";
          username = "geoffreygarrett";
          hostname = "artemis";
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

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
        // forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
    };
}
