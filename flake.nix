{
  description = "Cross-platform terminal setup with Home Manager";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
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

  outputs = { self, nixpkgs, home-manager, pre-commit-hooks, nixgl, systems, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      overlays = [ nixgl.overlay ];
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        }
      );
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      homeConfigurations = {
        "geoffrey@apollo" = lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          modules = [ ./nix/home/geoffrey/apollo.nix ./nix/hosts/apollo.nix ];
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
        "geoffreygarrett@artemis" = lib.homeManagerConfiguration {
          pkgs = pkgsFor.aarch64-darwin;
          modules = [ ./nix/darwin ./nix/home/geoffrey/artemis.nix ./nix/hosts/artemis.nix ];
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
      };
      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
        // forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            beautysh.enable = true;
            commitizen.enable = true;
          };
        };
      });

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor.${system};
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
            program = toString (pkgs.writeShellScript "home-manager-switch" (builtins.readFile ./scripts/home_manager_switch.sh));
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
