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
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Security
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
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
    nikitabobko-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    # Linux-specific
    nixgl = {
      url = "github:guibou/nixGL";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
    };

    # NixOS
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # CLI
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Browser
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    # Custom
    nixus = {
      url = "path:./nixus";
      flake = true;
      # type = "path";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      pre-commit-hooks,
      treefmt-nix,
      nixgl,
      disko,
      nixvim,
      darwin,
      xremap-flake,
      nix-homebrew,
      nix-on-droid,
      rust-overlay,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      nikitabobko-aerospace,
      ...
    }@inputs:
    let
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
        # Nix-on-Droid does not support the following systems
        # "armv7-linux"
        # "armv8-linux"
        # "x86_64-linux"
      ];
      allowed-unfree-packages = [
        "lmstudio"
        "nvidia"
        "mendeley"
      ];
      systems.supported = systems.linux ++ systems.darwin ++ systems.android;

      lib =
        nixpkgs.lib
        // home-manager.lib
        // {
          isLinux = system: builtins.elem system systems.linux;
          isDarwin = system: builtins.elem system systems.darwin;
          isAndroid = system: builtins.elem system systems.android;
          forAllSystems = f: nixpkgs.lib.genAttrs systems.supported f;
          forAllDarwinSystems = f: nixpkgs.lib.genAttrs systems.darwin f;
          forAllLinuxSystems = f: nixpkgs.lib.genAttrs systems.linux f;
          forAllAndroidSystems = f: nixpkgs.lib.genAttrs systems.android f;
          readSSHKeys = path: lib.splitString "\n" (builtins.readFile path);
        };
      user = "geoffrey";
      keys = lib.readSSHKeys ./authorized_keys;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            allowInsecure = false;
            allowUnsupportedSystem = true;
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
          };
          overlays =
            let
              path = ./nix/overlays;
              overlayFiles =
                with builtins;
                filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
                  attrNames (readDir path)
                );
            in
            builtins.trace "Loading overlays: ${builtins.toString overlayFiles}" (
              map (n: import (path + ("/" + n))) overlayFiles
            )
            ++ [
              (final: prev: {
                nixus = self.packages.${system}.nixus;
              })
            ]
            ++ lib.optional (lib.isAndroid system) (
              final: prev: {
                nix-on-droid = nix-on-droid.packages.${system};
              }
            )
            ++ lib.optional (lib.isAndroid system) nix-on-droid.overlays.default
            ++ lib.optional (lib.isAndroid system) inputs.sops-nix.overlays.default
            ++ lib.optional (lib.isLinux system) nixgl.overlay;
        };
      treefmtEval = lib.forAllSystems (
        system: treefmt-nix.lib.evalModule (pkgsFor system) ./nix/formatter/default.nix
      );
    in
    {

      ##############################
      # Packages Configuration
      ##############################
      packages = lib.forAllSystems (
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
          hosts = pkgs.writeShellScriptBin "hosts" (builtins.readFile ./scripts/print_hosts.sh);
          alacritty = pkgs.alacritty;
        }
      );

      ##############################
      # Apps Configuration
      ##############################
      apps = lib.forAllSystems (
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
          switch = {
            type = "app";
            program = "${pkgs.writeScriptBin "switch" (builtins.readFile ./nix/apps/switch.sh)}/bin/switch";
          };
          build = {
            type = "app";
            program = "${pkgs.writeScriptBin "build" (builtins.readFile ./nix/apps/build.sh)}/bin/build";
          };
          deploy = {
            type = "app";
            program = "${pkgs.writeScriptBin "deploy" (builtins.readFile ./nix/apps/deploy.sh)}/bin/deploy";
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
      darwinConfigurations =
        let
          specialArgs = {
            inherit
              inputs
              self
              user
              keys
              ;
          };
          homeManagerModule = {
            home-manager.sharedModules = [
              ./nix/modules/shared/colors.nix
            ];
          };
          nixHomebrewModule = {
            nix-homebrew = {
              inherit user;
              enable = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "nikitabobko/homebrew-tap" = nikitabobko-aerospace;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          };
        in
        {
          "artemis" = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            inherit specialArgs;
            pkgs = pkgsFor "aarch64-darwin";
            modules = [
              { networking.hostName = "artemis"; }
              ./nix/hosts/darwin/artemis
              homeManagerModule
              nixHomebrewModule
            ];
          };
        }
        // lib.forAllDarwinSystems (
          system:
          darwin.lib.darwinSystem {
            inherit system specialArgs;
            pkgs = pkgsFor system;
            modules = [
              ./nix/hosts/darwin
              homeManagerModule
              nixHomebrewModule
            ];
          }
        );

      #
      #
      #
      # deploy-rs node configuration
      deploy.nodes.mariner-1 =
        let
          system = "x86_64-linux";
          pkgs = pkgsFor system;
        in
        {
          hostname =
            let
              getTailscaleIP = pkgs.writeShellScript "get-tailscale-ip" ''
                ${pkgs.tailscale}/bin/tailscale status --json | 
                ${pkgs.jq}/bin/jq -r '.Peer[] | select(.HostName == "rpi") | .TailscaleIPs[0]'
              '';
            in
            builtins.readFile (
              pkgs.runCommand "tailscale-ip" { } ''
                ${getTailscaleIP} > $out
              ''
            );
          profiles.system = {
            sshUser = "${user}";
            sshOpts = [ "-tt" ];
            magicRollback = false;
            path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.mariner-1;
            user = "root";
          };
        };

      ##############################
      # NixOS Configuration :nixos
      ##############################
      nixosConfigurations =
        let
          specialArgs = {
            inherit
              inputs
              self
              user
              keys
              ;
          };
          homeManagerModule = {
            home-manager = {
              backupFileExtension = "bak";
              sharedModules = [
                inputs.nixvim.homeManagerModules.nixvim
                ./nix/packages/shared/shell-aliases
                ./nix/modules/shared/colors.nix
              ];
              useGlobalPkgs = true;
              extraSpecialArgs = specialArgs;
              users.${user} = import ./nix/modules/nixos/home-manager.nix;
            };
          };
          mkMarinerNode = import ./nix/hosts/nixos/mariner/factory.nix {
            inherit self inputs;
            pkgs = pkgsFor "aarch64-linux";
            system = "aarch64-linux";
          };
        in
        {
          "apollo" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            pkgs = pkgsFor "x86_64-linux";
            modules = [
              { networking.hostName = "apollo"; }
              ./nix/hosts/nixos/apollo
              homeManagerModule
            ];
          };
          "mariner-1" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              (mkMarinerNode {
                inherit user keys;
                hostname = "mariner-1";
              })
            ];
          };
          "mariner-2" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              (mkMarinerNode {
                inherit user keys;
                hostname = "mariner-2";
              })
            ];
          };
        };
      # // lib.forAllLinuxSystems (
      #   system:
      #   nixpkgs.lib.nixosSystem {
      #     inherit system specialArgs;
      #     pkgs = pkgsFor system;
      #     modules = [
      #       ./nix/hosts/nixos
      #       homeManagerModule
      #     ];
      #   }
      # );

      ##############################
      # Nix-on-Droid Configuration :android
      ##############################
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = pkgsFor "aarch64-linux";
        modules = [
          ./nix/hosts/android
          {
            networking.hosts = {
              "100.116.122.19" = [ "artemis.tail" ];
              "100.64.241.11" = [ "crazy-diamond.tail" ];
              "100.92.233.30" = [ "crazy-phone.tail" ];
              "100.111.132.9" = [ "dodo-iphone.tail" ];
              "100.91.33.40" = [ "google-chromecast.tail" ];
              "100.98.196.120" = [ "nimbus.tail" ];
              "100.78.156.17" = [ "pioneer.tail" ];
              "100.112.193.127" = [ "voyager.tail" ];
            };
          }
          {
            home-manager.extraSpecialArgs = {
              inherit self inputs user;
            };
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nixvim.homeManagerModules.nixvim
              ./nix/packages/shared/shell-aliases
            ];
          }
        ];
      };

      ##############################
      # Home Configuration :home
      ##############################
      homeConfigurations = lib.forAllSystems (
        system:
        lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules =
            [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nixvim.homeManagerModules.nixvim
              ./nix/packages/shared/shell-aliases
            ]
            ++ lib.filter (m: m != null) [
              (if lib.isDarwin system then ./nix/modules/darwin/default.nix else null)
              (if lib.isLinux system then ./nix/modules/linux/default.nix else null)
            ];
          extraSpecialArgs = {
            inherit
              self
              inputs
              user
              ;
          };
        }
      );

      ##############################
      # Checks Configuration :checks
      ##############################
      checks =
        nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
        // lib.forAllSystems (system: {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              beautysh.enable = true;
              commitizen.enable = true;
            };
          };
        });

      ##############################
      # Formatter Configuration :formatter
      ##############################
      formatter = lib.forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      ##############################
      # Dev Shell Configuration :devShells
      ##############################
      devShells = lib.forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
        };
      });
    };
}
