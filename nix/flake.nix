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
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      mkHomeConfiguration = { system, username, hostname, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = [
            ./home/default.nix
            {
              home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "22.11";
              };
              alacritty.configContent = builtins.readFile ../config/alacritty/alacritty.toml;
              zsh.rc = builtins.readFile ../config/zsh/.zshrc;
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
             ./hosts/geoffrey-linux-pc.nix
           ];
         };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
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

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          shellsModule = import ./shells { inherit pkgs home-manager system; };
        in
        shellsModule
      );
    };
}