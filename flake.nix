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
      url = "path:/home/geoffrey/.dotfiles/nixus";
      flake = true;
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      # url = "github:serokell/deploy-rs/pull/271/head"; # concurrent remote builds
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argon40-nix.url = "github:guusvanmeerveld/argon40-nix";
    impermanence.url = "github:nix-community/impermanence";
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
          readSSHKeys = path: (builtins.fromTOML (builtins.readFile path)).authorized_keys;
        };
      user = "geoffrey";
      keys = lib.readSSHKeys ./.nixus.toml;
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
            map (n: import (path + ("/" + n))) overlayFiles
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
      sharedDnsmasqConfig = {
        enable = true;
        # debugMode = true;
        hosts = {
          "pioneer.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.102";
                type = "local";
              }
              {
                ip = "100.78.156.17";
                type = "tailscale";
              }
            ];
          };
          "voyager.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.113";
                type = "local";
              }
              {
                ip = "100.112.193.127";
                type = "tailscale";
              }
            ];
          };
          "mariner-1.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.109";
                type = "local";
              }
            ];
          };
          "mariner-3.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.122";
                type = "local";
              }
              {
                ip = "100.126.29.41";
                type = "tailscale";
              }
            ];
          };
          "mariner-4.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.121";
                type = "local";
              }
              {
                ip = "100.112.163.77";
                type = "tailscale";
              }
            ];
          };
          "cassini.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.131";
                type = "local";
              }
            ];
          };

        };

        # extraConfig = ''
        #   log-queries
        #   log-facility=/var/log/dnsmasq.log
        # '';
        settings = {
          server = [
            "1.1.1.1" # Cloudflare primary
            "1.0.0.1" # Cloudflare secondary
            "9.9.9.9" # Quad9 primary
            "149.112.112.112" # Quad9 secondary
            "8.8.8.8" # Google primary
            "8.8.4.4" # Google secondary
          ];
          cache-size = 1000;
          no-resolv = true;
          # dnssec = true;
          dnssec-check-unsigned = true;
          domain-needed = true;
          bogus-priv = true;
        };
      };
      formatHosts =
        dnsSettings:
        lib.concatStringsSep "\n" (
          lib.flatten (
            lib.mapAttrsToList (
              hostname: entry: map (addr: "${addr.ip} ${hostname}") entry.addresses
            ) dnsSettings
          )
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
          flash = {
            type = "app";
            program = "${import ./nix/apps/flash.nix { inherit pkgs; }}/bin/nixos-sd-flasher";
          };
          nixus = {
            type = "app";
            program = "${nixusApp}/bin/nixus";
          };
          sync = {
            type = "app";
            program = "${import ./nix/apps/sync.nix { inherit pkgs; }}/bin/sync";
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
              # inputs.nixus.darwinModules.dnsmasq
              # { nixus.dnsmasq = sharedDnsmasqConfig; }
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

      ##############################
      # Deploy Nodes :deploy
      ##############################
      deploy = {
        nodes =
          let
            commonSshOpts = [
              # "-o"
              # "StrictHostKeyChecking=no"
              # "-o"
              # "UserKnownHostsFile=/dev/null"
            ];
            activateNixOnDroid =
              configuration:
              inputs.deploy-rs.lib.aarch64-linux.activate.custom configuration.activationPackage "${configuration.activationPackage}/activate";
          in
          {

            "cassini" = {
              hostname = "cassini.nixus.net";
              profiles.system = {
                # Build the derivation on the target system.
                # Will also fetch all external dependencies from the target system's substituters.
                # This default to `false`. If the target system does not have the trusted keys, set this to `true`.
                remoteBuild = false;
                sshUser = "${user}";
                user = "root";
                magicRollback = true;
                interactiveSudo = true;
                sshOpts = commonSshOpts;
                # sshOpts = commonSshOpts ++ [
                #   # # NOTE: This is a workaround for "too many root sets":
                #   # # https://github.com/NixOS/nix/issues/7359
                #   "-o"
                #   "ProxyCommand=none"
                #   "-t" # pseudo-terminal allocation for password prompt
                # ];
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.cassini;
              };
            };

            "mariner-1" = {
              hostname = "mariner-1.nixus.net";
              profiles.system = {
                sshUser = "${user}";
                user = "root";
                magicRollback = true;
                sshOpts = commonSshOpts;
                path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.mariner-1;
              };
            };

            "mariner-3" = {
              hostname = "mariner-3.nixus.net";
              profiles.system = {
                sshUser = "${user}";
                user = "root";
                magicRollback = true;
                sshOpts = commonSshOpts;
                path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.mariner-3;
              };
            };

            "mariner-4" = {
              # Raspberry Pi 3B+
              hostname = "mariner-4.nixus.net";
              profiles.system = {
                sshUser = "${user}";
                user = "root";
                magicRollback = true;
                sshOpts = commonSshOpts;
                path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.mariner-4;
              };
            };

            "pioneer" = {
              # Samsung S20 Ultra
              hostname = "pioneer.nixus.net";
              profiles.system = {
                confirmTimeout = 60;
                sshUser = "nix-on-droid";
                user = "nix-on-droid";
                magicRollback = true;
                sshOpts = commonSshOpts ++ [
                  "-p"
                  "8022"
                ];
                path = activateNixOnDroid self.nixOnDroidConfigurations.pioneer;
              };
            };

            "voyager" = {
              # Samsung Galaxy Tab S7
              hostname = "voyager.nixus.net";
              profiles.system = {
                sshUser = "nix-on-droid";
                user = "nix-on-droid";
                magicRollback = true;
                sshOpts = commonSshOpts ++ [
                  "-p"
                  "8022"
                ];
                path = activateNixOnDroid self.nixOnDroidConfigurations.voyager;
              };
            };
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
              ./nix/hosts/nixos/apollo
              homeManagerModule
              inputs.nixus.nixosModules.dnsmasq
              { nixus.dnsmasq = sharedDnsmasqConfig; }
            ];
          };

          "cassini" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            pkgs = pkgsFor "x86_64-linux";
            modules = [
              ./nix/hosts/nixos/cassini
              homeManagerModule
              inputs.nixus.nixosModules.dnsmasq
              { nixus.dnsmasq = sharedDnsmasqConfig; }
            ];
          };

          "mariner-1" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./nix/hosts/nixos/mariner/1
              inputs.nixus.nixosModules.dnsmasq
              { nixus.dnsmasq = sharedDnsmasqConfig; }
              # (mkMarinerNode {
              #   inherit user keys;
              #   hostname = "mariner-1";
              # })
              # inputs.nixos-hardware.nixosModules.raspberry-pi-4
              # inputs.argon40-nix.nixosModules.default
              # inputs.nixus.nixosModules.dnsmasq
              # { nixus.dnsmasq = sharedDnsmasqConfig; }
            ];
          };

          "mariner-3" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              (mkMarinerNode {
                inherit user keys;
                hostname = "mariner-3";
              })
              inputs.nixos-hardware.nixosModules.raspberry-pi-3
              inputs.nixus.nixosModules.dnsmasq
              { nixus.dnsmasq = sharedDnsmasqConfig; }
            ];
          };

          "mariner-4" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              (mkMarinerNode {
                inherit user keys;
                hostname = "mariner-4";
              })
              inputs.nixos-hardware.nixosModules.raspberry-pi-3
              inputs.nixus.nixosModules.dnsmasq
              { nixus.dnsmasq = sharedDnsmasqConfig; }
            ];
          };

          "rpi-4-bootstrap" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./nix/hosts/nixos/bootstrap/rpi-4.nix
              { networking.hostName = lib.mkForce "rpi-4-bootstrap"; }
            ];
          };

          "rpi-3-bootstrap" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./nix/hosts/nixos/bootstrap/rpi-3.nix
              { networking.hostName = lib.mkForce "rpi-3-bootstrap"; }
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
      #   }/home/geoffrey/Downloads/nix-flake-logo.png 
      # );

      ##############################
      # Nix-on-Droid Configuration :nix-on-droid
      ##############################
      nixOnDroidConfigurations =
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
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
                inputs.nixvim.homeManagerModules.nixvim
                ./nix/packages/shared/shell-aliases
              ];
              extraSpecialArgs = specialArgs;
            };
          };
          networkingModule = {
            networking.extraHosts = formatHosts sharedDnsmasqConfig.hosts;
          };
        in
        {

          "pioneer" = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = pkgsFor "aarch64-linux";
            extraSpecialArgs = specialArgs;
            modules = [
              ./nix/hosts/nix-on-droid/pioneer
              homeManagerModule
              networkingModule
            ];
          };

          "voyager" = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = pkgsFor "aarch64-linux";
            extraSpecialArgs = specialArgs;
            modules = [
              ./nix/hosts/nix-on-droid/voyager
              homeManagerModule
              networkingModule
            ];
          };

          default = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = pkgsFor "aarch64-linux";
            extraSpecialArgs = specialArgs;
            modules = [
              ./nix/hosts/nix-on-droid
              homeManagerModule
              networkingModule
            ];
          };

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
              # nixfmt-rfc-style.enable = true;
              # beautysh.enable = true;
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
