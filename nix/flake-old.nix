#{
#  description = "NixOS configuration";
#
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    sops-nix = {
#      url = "github:Mic92/sops-nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    firefox-addons = {
#      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#  };
#
#  outputs = {
#    nixpkgs,
#    home-manager,
#    ...
#  } @ inputs: {
#     # Define packages or other outputs if needed
#      packages.x86_64-linux = let
#        # Define custom packages here, e.g., `myPackage = pkgs.callPackage ./path/to/package.nix {};`
#      in {
#        inherit nixpkgs;
#      };
#    os = {
#        system = "x86_64-linux";
#        modules = [
#            ./hosts/geoffrey-linux-pc.nix
#            ./modules
#            {nixpkgs.config.allowUnfree = true;}
#            home-manager.nixosModules.home-manager
#            {
#            home-manager.useGlobalPkgs = true;
#            home-manager.useUserPackages = true;
#            home-manager.users.geoffrey = import ./home/default.nix;
#            home-manager.extraSpecialArgs = {inherit inputs;};
##            home-manager.sharedModules = [
##                inputs.sops-nix.homeManagerModules.sops
##            ];
#            }
#        ];
#        specialArgs = {inherit inputs;};
#        };
#
##      buddha = nixpkgs.lib.nixosSystem {
##        system = "x86_64-linux";
##        modules = [
##          ./hosts/buddha.nix
##          ./modules
##          {nixpkgs.config.allowUnfree = true;}
##          home-manager.nixosModules.home-manager
##          {
##            home-manager.useGlobalPkgs = true;
##            home-manager.useUserPackages = true;
##            home-manager.users.senoraraton = import ./home-manager/default.nix;
##            home-manager.extraSpecialArgs = {inherit inputs;};
##            home-manager.sharedModules = [
##              inputs.sops-nix.homeManagerModules.sops
##            ];
##          }
##        ];
##        specialArgs = {inherit inputs;};
##      };
##      samsara = nixpkgs.lib.nixosSystem {
##        system = "x86_64-linux";
##        modules = [
##          ./hosts/samsara.nix
##          ./modules
##          {nixpkgs.config.allowUnfree = true;}
##          home-manager.nixosModules.home-manager
##          {
##            home-manager.useGlobalPkgs = true;
##            home-manager.useUserPackages = true;
##            home-manager.users.senoraraton = import ./home-manager/default.nix;
##            home-manager.extraSpecialArgs = {inherit inputs;};
##          }
##        ];
##      };
##      moksha = nixpkgs.lib.nixosSystem {
##        system = "x86_64-linux";
##        modules = [
##          ./hosts/moksha.nix
##          ./modules
##          {nixpkgs.config.allowUnfree = true;}
##          home-manager.nixosModules.home-manager
##          {
##            home-manager.useGlobalPkgs = true;
##            home-manager.useUserPackages = true;
##            home-manager.users.senoraraton = import ./home-manager/default.nix;
##            home-manager.extraSpecialArgs = {inherit inputs;};
##          }
##        ];
##      };
##    };
#  };
#}
#
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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... } @ inputs:
    let
      mkSystem = import ./lib/mksystem.nix;
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        geoffrey-linux-pc = mkSystem "x86_64-linux" "geoffrey" {
          imports = [
            ./hosts/geoffrey-linux-pc.nix
            ./modules/nixos
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.geoffrey = import ./home/default.nix;
            }
          ];
        };
        # Add more NixOS configurations here
      };

#      # macOS configurations
#      darwinConfigurations = {
#        "geoffrey-macbook" = darwin.lib.darwinSystem {
#          system = "aarch64-darwin";
#          modules = [
#            ./hosts/geoffrey-macbook.nix
#            ./modules/darwin
#            home-manager.darwinModules.home-manager
#            {
#              home-manager.useGlobalPkgs = true;
#              home-manager.useUserPackages = true;
#              home-manager.users.geoffrey = import ./home/default.nix;
#            }
#          ];
#        };
#        # Add more macOS configurations here
#      };

#      # Home Manager configurations (for non-NixOS Linux, like Ubuntu)
#      homeConfigurations = {
#        "geoffrey@ubuntu-desktop" = home-manager.lib.homeManagerConfiguration {
#          pkgs = nixpkgs.legacyPackages.x86_64-linux;
#          modules = [
#            ./hosts/geoffrey-linux-pc.nix
#            {
#              home = {
#                username = "geoffrey";
#                homeDirectory = "/home/geoffrey";
#              };
#            }
#          ];
#          extraSpecialArgs = { inherit inputs; };
#        };
#        # Add more Home Manager configurations here
#      };

      # Packages
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          myScript = pkgs.writeShellScriptBin "hello" ''
            echo "Hello, World!"
          '';
        }
      );
    };
}