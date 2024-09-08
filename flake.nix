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

    # Custom Packages
    custom-packages = {
      url = "./nix/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS-specific
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

    # Linux-specific
    nixgl = { url = "github:guibou/nixGL"; };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , pre-commit-hooks
    , custom-packages
      # LINUX
    , nixgl
      # DARWIN
    , darwin
    , nix-homebrew
    , homebrew-bundle
    , homebrew-core
    , homebrew-cask
      # ANDROID
    , nix-on-droid
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      users = {
        geoffrey = {
          username = "geoffrey";
          full-name = "Geoffrey Garrett";
          email = "geoffrey@example.com";
          github-username = "geoffreygarrett";
        };
      };
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
                age
                sops
                age-plugin-yubikey
                neovim
              ];
              shellHook = with pkgs; ''
                export EDITOR=nvim
              '';
            };
        };
      lib = nixpkgs.lib // home-manager.lib;
      user = "geoffreygarrett";
      systems.linux = [ "aarch64-linux" "x86_64-linux" ];
      systems.darwin = [ "aarch64-darwin" "x86_64-darwin" ];
      systems.supported = systems.linux ++ systems.darwin;
      forAllSystems = f: nixpkgs.lib.genAttrs (systems.supported) f;
      isLinux = system: builtins.elem system systems.linux;
      isTermuxNixAndroid = builtins.getEnv "TERMUX_APP__PACKAGE_NAME" == "com.termux.nix";
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
      mkRustScriptApp =
        import ./nix/lib/mk-rust-script-app.nix { inherit inputs nixpkgs lib; };
      mkRustBinaryApp =
        import ./nix/lib/mk-rust-binary-app.nix { inherit inputs nixpkgs lib; };
      mkLinuxConfiguration = import ./nix/lib/mk-nixos-configuration.nix {
        inherit inputs nixpkgs lib;
      };
      mkLinuxApps = system: {
        "apply" = mkRustScriptApp "apply" system;
        "build-switch" = mkRustScriptApp "build-switch" system;
        "copy-keys" = mkRustScriptApp "copy-keys" system;
        "create-keys" = mkRustScriptApp "create-keys" system;
        "check-keys" = mkRustScriptApp "check-keys" system;
        "install" = mkRustScriptApp "install" system;
        "install-with-secrets" = mkRustScriptApp "install-with-secrets" system;
      };
      mkDarwinApps = system: {
        "apply" = mkRustScriptApp "apply" system;
        "build" = mkRustScriptApp "build" system;
        "build-switch" = mkRustScriptApp "build-switch" system;
        "copy-keys" = mkRustScriptApp "copy-keys" system;
        "create-keys" = mkRustScriptApp "create-keys" system;
        "check-keys" = mkRustScriptApp "check-keys" system;
        "rollback" = mkRustScriptApp "rollback" system;
      };

    in
    {
      services.nix-daemon.enable = true;
      services.pcscd.enable = true;
      home-manager.syncthing = {
        enable = true;
        tray.enable = true;
        key = "...";
        cert = "...";
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
            ./nix/home/apollo.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "geoffreygarrett@artemis" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          modules = [
            ./nix/hosts/artemis.nix
            ./nix/home/artemis.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
          extraSpecialArgs = { inherit inputs outputs; };
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

      ##############################
      # Nix-on-Droid Configuration
      ##############################
      nixOnDroidConfigurations = {
        default = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = pkgsFor "aarch64-linux";
          modules = [
            ./nix/home/modules/android
            inputs.sops-nix.homeManagerModules.sops
            {
              networking.hosts = {
                "100.78.156.17" = [ "pioneer.home" ];
                "100.116.122.19" = [ "artemis.home" ];
              };
            }
          ];
          extraSpecialArgs = { inherit inputs outputs; };
          home-manager-path = home-manager.outPath;
        };
      };

      ##############################
      # Darwin Configuration
      ##############################
      darwinConfigurations = nixpkgs.lib.genAttrs systems.darwin (system:
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
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules =
                [ inputs.sops-nix.homeManagerModules.sops ];
              #            home-manager.users.${user} = import ./nix/home/artemis.nix;
            }
            ./nix/hosts/darwin
          ];
          specialArgs = { inherit inputs; };
        });
      #
      # apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      apps = forAllSystems (system:
        let pkgs = pkgsFor system;
        in
        {
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
      #      devShells = forAllSystems devShell;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });

    };
}
