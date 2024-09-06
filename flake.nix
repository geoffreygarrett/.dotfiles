{
  description = "General Purpose Configuration for macOS and NixOS";
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
    nixgl = { url = "github:guibou/nixGL"; };
  };
  outputs =
    { self, nixpkgs, home-manager, pre-commit-hooks, nixgl, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems.linux = [ "aarch64-linux" "x86_64-linux" ];
      systems.darwin = [ "aarch64-darwin" "x86_64-darwin" ];
      systems.supported = systems.linux ++ systems.darwin;
      forAllSystems = f: nixpkgs.lib.genAttrs (systems.supported) f;
      isLinux = system: builtins.elem system systems.linux;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = lib.optionals (isLinux system) [ nixgl.overlay ];
          config.allowUnfree = true;
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

      # Function to configure WireGuard for both macOS and Linux
      configureWireguard = system:
        let
          wg_conf = pkgsFor (system).writeTextFile {
            name = "wg0.conf";
            text = builtins.readFile ./secrets/wg0.conf; # Your encrypted wg0.conf (managed by sops)
          };
        in
        pkgsFor (system).mkShell {
          buildInputs = [ pkgsFor (system).wireguard-tools pkgsFor (system).sops-nix ];
          shellHook = ''
            sops -d ${wg_conf} | sudo tee /etc/wireguard/wg0.conf
            sudo wg-quick up wg0
          '';
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
    in
    {
      services.pcscd.enable = true;
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      home-manager.syncthing.enable = true;
      home-manager.syncthing.tray.enable = true;
      homeConfigurations = {
        "geoffrey@apollo" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./nix/home/geoffrey/apollo.nix ./nix/hosts/apollo.nix ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "geoffreygarrett@artemis" = lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          modules = [
            ./nix/darwin
            ./nix/hosts/artemis.nix
            ./nix/home/geoffrey/artemis.nix

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
        } // (if isLinux system then mkLinuxApps else mkDarwinApps) system
      );

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
    };
}
