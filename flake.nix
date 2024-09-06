{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    custom-packages = {
      url = "./nix/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = { url = "github:zhaofengli-wip/nix-homebrew"; };
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
    nixgl = { url = "github:guibou/nixGL"; };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , pre-commit-hooks
    , nixgl
    , custom-packages
    , nix-darwin
    , nix-homebrew
    , homebrew-bundle
    , homebrew-core
    , homebrew-cask
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      user = "geoffrey";
      lib = nixpkgs.lib // home-manager.lib;
      systems.linux = [ "aarch64-linux" "x86_64-linux" ];
      systems.darwin = [ "aarch64-darwin" "x86_64-darwin" ];
      systems.supported = systems.linux ++ systems.darwin;
      forAllSystems = f: nixpkgs.lib.genAttrs (systems.supported) f;
      isLinux = system: builtins.elem system systems.linux;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [
            custom-packages.overlays.default
            (final: prev:
              nixpkgs.lib.optionalAttrs (isLinux system)
                (nixgl.overlays.default final prev))
          ];
          config = {
            allowUnfree = true;
            allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [ "tailscale-ui" ];
          };
        };
      mkApp = name: system:
        let
          pkgs = pkgsFor system;
          scriptDir = pkgs.runCommand "${name}-dir" { } ''
            mkdir -p $out
            cp ${./nix/apps/${name}.rs} $out/${name}.rs
            cp ${./nix/apps/shared.rs} $out/shared.rs
          '';
        in
        {
          type = "app";
          program = toString (pkgs.writers.writeBash name ''
            export PATH=${pkgs.git}/bin:${pkgs.rust-script}/bin:$PATH
            exec rust-script ${scriptDir}/${name}.rs
          '');
        };

      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      };

      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };

      #      mkApp = scriptName: system: {
      #        type = "app";
      #        program = "${
      #            (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
      #              #!/usr/bin/env bash
      #              PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
      #              echo "Running ${scriptName} for ${system}"
      #              exec ${self}/apps/${system}/${scriptName}
      #            '')
      #          }/bin/${scriptName}";
      #      };
      #      mkLinuxApps = system: {
      #        "apply" = mkApp "apply" system;
      #        "build-switch" = mkApp "build-switch" system;
      #        "copy-keys" = mkApp "copy-keys" system;
      #        "create-keys" = mkApp "create-keys" system;
      #        "check-keys" = mkApp "check-keys" system;
      #        "install" = mkApp "install" system;
      #        "install-with-secrets" = mkApp "install-with-secrets" system;
      #      };
      #      mkDarwinApps = system: {
      #        "apply" = mkApp "apply" system;
      #        "build" = mkApp "build" system;
      #        "build-switch" = mkApp "build-switch" system;
      #        "copy-keys" = mkApp "copy-keys" system;
      #        "create-keys" = mkApp "create-keys" system;
      #        "check-keys" = mkApp "check-keys" system;
      #        "rollback" = mkApp "rollback" system;
      #      };

      darwinConfigurations = nixpkgs.lib.genAttrs systems.darwin (system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
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
            ./hosts/darwin
            #homeConfigurations."geoffreygarrett@artemis"
          ];
        });

      # Define the networking configuration
      networkingConfig = {
        nat = {
          enable = true;
          externalInterface = "eth0";
          internalInterfaces = [ "wg0" ];
        };
        firewall = {
          enable = true;
          allowedUDPPorts = [ 51820 ]; # Port for WireGuard
        };
      };

    in
    {
      services.nix-daemon.enable = true;
      services.pcscd.enable = true;
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      home-manager.syncthing.enable = true;
      home-manager.syncthing.tray.enable = true;
      homeConfigurations = {
        "geoffrey@apollo" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules =
            [ ./nix/network.nix ./nix/hosts/apollo.nix ./nix/home/apollo.nix ];
          extraSpecialArgs = { inherit inputs outputs networkingConfig; };
        };
        "geoffreygarrett@artemis" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          modules = [
            ./nix/hosts/artemis.nix
            ./nix/home/artemis.nix
          ];
          extraSpecialArgs = { inherit inputs outputs networkingConfig; };
        };
      };
      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage)
        self.homeConfigurations // forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            beautysh.enable = true;
            commitizen.enable = true;
          };
        };
      });

      #      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      apps = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          check = {
            type = "app";
            program = toString (pkgs.writeShellScript "run-checks" ''
              ${self.checks.${system}.pre-commit-check.shellHook}
              pre-commit run --all-files
            '');
          };
          switch = {
            type = "app";
            program = toString (pkgs.writeShellScript "home-manager-switch"
              (builtins.readFile ./scripts/home_manager_switch.sh));
          };
        } // (if isLinux system then mkLinuxApps else mkDarwinApps) system);

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
    };
}
