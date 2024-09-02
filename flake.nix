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

  outputs = { self, nixpkgs, home-manager, darwin, ... } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      mkHomeConfiguration = { system, username, hostname, extraModules ? [ ] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = [
            ./nix/home-manager/default.nix
            {
              home = {
                inherit username;
                homeDirectory =
                  if system == "aarch64-darwin"
                  then "/Users/${username}"
                  else "/home/${username}";
                stateVersion = "22.11";
              };
            }
          ] ++ extraModules;
          extraSpecialArgs = {
            inherit inputs;
            currentSystem = system;
            currentHostname = hostname;
          };
        };

    in
    {
      homeConfigurations = {
        "geoffrey@geoffrey-linux-pc" = mkHomeConfiguration {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "geoffrey-linux-pc";
          extraModules = [
            #            ./nix/hosts/geoffrey-linux-pc.nix
          ];
        };
        "geoffreygarrett@geoffreys-macbook-air" = mkHomeConfiguration {
          system = "aarch64-darwin";
          username = "geoffreygarrett";
          hostname = "geoffreys-macbook-air";
          extraModules = [
            #            ./nix/hosts/geoffreys-macbook-air.nix
          ];
        };
      };

      shellConfigurations = {
        "full" = {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "geoffrey-linux-pc";
          extraModules = [
            ./nix/shells/full.nix
          ];
        };
        "base" = {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "geoffrey-linux-pc";
          extraModules = [
            ./nix/shells/base.nix
          ];
        };
        "dev" = {
          system = "x86_64-linux";
          username = "geoffrey";
          hostname = "geoffrey-linux-pc";
          extraModules = [
            ./nix/shells/dev.nix
          ];
        };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.writeShellScriptBin "default-script" ''
            echo "This is the default package for the flake."
          '';
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.default);

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/default-script";
        };
      });

      devShells = forAllSystems (system: {
        default = import ./nix/shells/default.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
        base = import ./nix/shells/base.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
        full = import ./nix/shells/full.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
      });

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
    };
}
