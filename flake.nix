{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System Management
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Security
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development Tools
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS-specific
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Linux-specific
    nixgl = {
      url = "github:guibou/nixGL";
    };

    # CLI
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      pre-commit-hooks,
      treefmt-nix,
      nixgl,
      darwin,
      nix-homebrew,
      nix-on-droid,
      rust-overlay,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      user =
        let
          envUser = builtins.getEnv "USER";
        in
        if envUser != "" then envUser else "geoffreygarrett";
      systems.linux = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      systems.darwin = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      systems.android = [
        "aarch64-linux"
        "armv7-linux"
        "armv8-linux"
        "x86_64-linux"
      ];
      systems.supported = systems.linux ++ systems.darwin ++ systems.android;
      lib =
        nixpkgs.lib
        // home-manager.lib
        // {
          isLinux = system: builtins.elem system systems.linux;
          isDarwin = system: builtins.elem system systems.darwin;
          isAndroid = system: builtins.elem system systems.android;
        };
      forAllSystems = f: nixpkgs.lib.genAttrs systems.supported f;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays =
            [
              (final: prev: {
                nix-on-droid = nix-on-droid.packages.${system};
                nixus = self.packages.${system}.nixus;
              })
            ]
            ++ lib.optional (lib.isAndroid system) nix-on-droid.overlays.default
            ++ lib.optional (lib.isLinux system) nixgl.overlay;
        };
      treefmtEval = forAllSystems (
        system: treefmt-nix.lib.evalModule (pkgsFor system) ./nix/formatter/default.nix
      );
    in
    {
      ##############################
      # Packages Configuration
      ##############################
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          nixus = import ./nix/apps/nixus {
            inherit
              system
              pkgs
              rust-overlay
              lib
              nix-on-droid
              ;
          };
        }
      );

      ##############################
      # Apps Configuration
      ##############################
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          nixusApp = self.packages.${system}.nixus;
        in
        {
          default = {
            type = "app";
            program = "${nixusApp}/bin/nixus";
          };

          nixus = {
            type = "app";
            program = "${nixusApp}/bin/nixus";
          };

          check = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "run-checks" ''
              ${self.checks.${system}.pre-commit-check.shellHook}
              pre-commit run --all-files
            ''}/bin/run-checks";
          };
        }
      );

      ##############################
      # Darwin Configuration
      ##############################
      darwinConfigurations = nixpkgs.lib.genAttrs systems.darwin (
        system:
        darwin.lib.darwinSystem {
          inherit system;
          pkgs = pkgsFor system;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./nix/hosts/darwin
          ];
          specialArgs = {
            inherit inputs self user;
          };
        }
      );

      ##############################
      # Nix-on-Droid Configuration
      ##############################
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = pkgsFor "aarch64-linux";
        modules = [
          ./nix/hosts/android
          {
            networking.hosts = {
              "100.78.156.17" = [ "pioneer.home" ];
              "100.116.122.19" = [ "artemis.home" ];
            };
          }
          {
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
            };
            home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
          }
        ];
      };

      ##############################
      # Home Configuration
      ##############################
      homeConfigurations = {
        "geoffrey@apollo" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules = [
            ./nix/network.nix
            ./nix/hosts/apollo.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
        "geoffreygarrett@artemis" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          modules = [
            ./nix/hosts/artemis.nix
            ./nix/home/artemis.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
      };

      ##############################
      # Checks Configuration
      ##############################
      checks =
        nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
        // forAllSystems (system: {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              beautysh.enable = true;
              rustfmt.enable = true;
              commitizen.enable = true;
            };
          };
        });

      ##############################
      # Formatter Configuration
      ##############################
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      ##############################
      # Dev Shell Configuration
      ##############################
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
        };
      });
    };
}
