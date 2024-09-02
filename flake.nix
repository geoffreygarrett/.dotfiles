#{
#  description = "Cross-platform terminal setup with Home Manager";
#
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    darwin = {
#      url = "github:lnl7/nix-darwin/master";
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
#  outputs = { self, nixpkgs, home-manager, darwin, ... } @ inputs:
#    let
#      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
#      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
#      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
#      dotConfigImport = import ../config {
#        pkgs = nixpkgsFor.${builtins.currentSystem};
#        lib = nixpkgs.lib;
#      };
#      mkHomeConfiguration = { system, username, hostname, extraModules ? [] }:
#        home-manager.lib.homeManagerConfiguration {
#          pkgs = nixpkgsFor.${system};
#          modules = [
#            ./home/default.nix
#            dotConfigImport.config
#            {
#              home = {
#                inherit username;
#                homeDirectory = "/home/${username}";
#                stateVersion = "22.11";
#              };
#              alacritty.configContent = dotConfigImport.config.alacritty.configContent;
#              zsh.rc = dotConfigImport.config.zsh.content;
#            }
#          ] ++ extraModules;
#          extraSpecialArgs = {
#            inherit inputs;
#            currentSystem = system;
#            currentHostname = hostname;
#          };
#        };
#    in
#    {
#      homeConfigurations = {
#         "geoffrey@geoffrey-linux-pc" = mkHomeConfiguration {
#           system = "x86_64-linux";
#           username = "geoffrey";
#           hostname = "geoffrey-linux-pc";
#           extraModules = [
#             ./hosts/geoffrey-linux-pc.nix
#           ];
#         };
#      };
#
#      packages = forAllSystems (system:
#        let pkgs = nixpkgsFor.${system};
#        in {
#          default = pkgs.writeShellScriptBin "default-script" ''
#            echo "This is the default package for the flake."
#          '';
#        }
#      );
#
#      defaultPackage = forAllSystems (system: self.packages.${system}.default);
#
#      apps = forAllSystems (system: {
#        default = {
#          type = "app";
#          program = "${self.packages.${system}.default}/bin/default-script";
#        };
#      });
#
#      devShells = forAllSystems (system:
#        let
#          pkgs = nixpkgsFor.${system};
#          shellsModule = import ./shells { inherit pkgs home-manager system; };
#        in
#        shellsModule
#      );
#    };
#}
#{
#  description = "Cross-platform terminal setup with Home Manager";
#
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    darwin = {
#      url = "github:lnl7/nix-darwin/master";
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
#  outputs = { self, nixpkgs, home-manager, darwin, ... } @ inputs:
#    let
#      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
#      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
#      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
#      dotConfigImport = import ../config {
#        pkgs = nixpkgsFor.${builtins.currentSystem};
#        lib = nixpkgs.lib;
#      };
#      mkHomeConfiguration = { system, username, hostname, extraModules ? [] }:
#        home-manager.lib.homeManagerConfiguration {
#          pkgs = nixpkgsFor.${system};
#          modules = [
#            ./home/default.nix
#            dotConfigImport.config
#            {
#              home = {
#                inherit username;
#                homeDirectory = "/home/${username}";
#                stateVersion = "22.11";
#              };
#              alacritty.configContent = dotConfigImport.config.alacritty.configContent;
#              zsh.rc = dotConfigImport.config.zsh.content;
#            }
#          ] ++ extraModules;
#          extraSpecialArgs = {
#            inherit inputs;
#            currentSystem = system;
#            currentHostname = hostname;
#          };
#        };
#    in
#    {
#      homeConfigurations = {
#         "geoffrey@geoffrey-linux-pc" = mkHomeConfiguration {
#           system = "x86_64-linux";
#           username = "geoffrey";
#           hostname = "geoffrey-linux-pc";
#           extraModules = [
#             ./hosts/geoffrey-linux-pc.nix
#           ];
#         };
#         "geoffreygarrett@geoffreys-macbook-air" = mkHomeConfiguration {
#           system = "aarch64-darwin";
#           username = "geoffreygarrett";
#           hostname = "geoffreys-macbook-air";
#           extraModules = [
#             ./hosts/geoffreys-macbook-air.nix
#           ];
#         };
#      };
#
#      packages = forAllSystems (system:
#        let pkgs = nixpkgsFor.${system};
#        in {
#          default = pkgs.writeShellScriptBin "default-script" ''
#            echo "This is the default package for the flake."
#          '';
#        }
#      );
#
#      defaultPackage = forAllSystems (system: self.packages.${system}.default);
#
#      apps = forAllSystems (system: {
#        default = {
#          type = "app";
#          program = "${self.packages.${system}.default}/bin/default-script";
#        };
#      });
#
#      devShells = forAllSystems (system:
#        let
#          pkgs = nixpkgsFor.${system};
#        in
#        pkgs.mkShell {
#          packages = with pkgs; [
#            home-manager.packages.${system}.home-manager
#            pkgs.neofetch
#            pkgs.zsh
#            pkgs.zellij
#            pkgs.spaceship-prompt
#            pkgs.coreutils
#            pkgs.inetutils
#            pkgs.findutils
#            pkgs.gnugrep
#          ];
#          nativeBuildInputs = [
#            home-manager.packages.${system}.home-manager
#            pkgs.neofetch
#            pkgs.zsh
#            pkgs.zellij
#            pkgs.spaceship-prompt
#            pkgs.coreutils
#            pkgs.inetutils
#            pkgs.findutils
#            pkgs.gnugrep
#          ];
#
#          shellHook = ''
#            export NIX_PATH="nixpkgs=${pkgs.path}:home-manager=${home-manager}"
#            export HOME_MANAGER_CONFIG="$PWD/home/default.nix"
#
#            # Source the .zshrc from the config directory
#            if [ -f $HOME/.config/zsh/.zshrc ]; then
#              source $HOME/.config/zsh/.zshrc
#            else
#              echo "Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration."
#              source /etc/zshrc
#            fi
#
#            # General options
#            neofetch
#          '';
#        }
#      );
#    };
#}
#{
#  description = "Cross-platform terminal setup with Home Manager";
#
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#    home-manager = {
#      url = "github:nix-community/home-manager";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    darwin = {
#      url = "github:lnl7/nix-darwin/master";
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
#  outputs = { self, nixpkgs, home-manager, darwin, ... } @ inputs:
#    let
#      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
#      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
#      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
#
#      dotConfigImport = import ../config {
#        pkgs = nixpkgsFor.${builtins.currentSystem};
#        lib = nixpkgs.lib;
#      };
#
#      mkHomeConfiguration = { system, username, hostname, extraModules ? [] }:
#        home-manager.lib.homeManagerConfiguration {
#          pkgs = nixpkgsFor.${system};
#          modules = [
#            ./home/default.nix
#            dotConfigImport.config
#            {
#              home = {
#                inherit username;
#                homeDirectory = if system == "aarch64-darwin"
#                  then "/Users/${username}"
#                  else "/home/${username}";
#                stateVersion = "22.11";
#              };
#              alacritty.configContent = dotConfigImport.config.alacritty.configContent;
#              zsh.rc = dotConfigImport.config.zsh.content;
#            }
#          ] ++ extraModules;
#          extraSpecialArgs = {
#            inherit inputs;
#            currentSystem = system;
#            currentHostname = hostname;
#          };
#        };
#
#      mkDevShell = system:
#        let
#          pkgs = nixpkgsFor.${system};
#          username = builtins.getEnv "USER";
#          hostname = builtins.getEnv "HOSTNAME";
#        in
#        pkgs.mkShell {
#          packages = with pkgs; [
#            home-manager.packages.${system}.home-manager
#            neofetch
#            zsh
#            zellij
#            spaceship-prompt
#            coreutils
#            inetutils
#            findutils
#            gnugrep
#          ];
#
#          shellHook = ''
#            export NIX_PATH="nixpkgs=${pkgs.path}:home-manager=${home-manager}"
#            export HOME_MANAGER_CONFIG="$PWD/home/default.nix"
#
#            # Source the .zshrc from the config directory
#            if [ -f $HOME/.config/zsh/.zshrc ]; then
#              source $HOME/.config/zsh/.zshrc
#            else
#              echo "Warning: $HOME/.config/zsh/.zshrc not found. Using default Zsh configuration."
#              if [ -f /etc/zshrc ]; then
#                source /etc/zshrc
#              else
#                echo "Warning: /etc/zshrc not found. No Zsh configuration sourced."
#              fi
#            fi
#
#            # General options
#            if command -v neofetch >/dev/null 2>&1; then
#              neofetch
#            else
#              echo "Warning: neofetch not found"
#            fi
#
#            echo "Development shell activated for ${username}@${hostname} on ${system}"
#          '';
#        };
#
#    in
#    {
#      homeConfigurations = {
#         "geoffrey@geoffrey-linux-pc" = mkHomeConfiguration {
#           system = "x86_64-linux";
#           username = "geoffrey";
#           hostname = "geoffrey-linux-pc";
#           extraModules = [
#             ./hosts/geoffrey-linux-pc.nix
#           ];
#         };
#         "geoffreygarrett@geoffreys-macbook-air" = mkHomeConfiguration {
#           system = "aarch64-darwin";
#           username = "geoffreygarrett";
#           hostname = "geoffreys-macbook-air";
#           extraModules = [
#             ./hosts/geoffreys-macbook-air.nix
#           ];
#         };
#      };
#
#      packages = forAllSystems (system:
#        let pkgs = nixpkgsFor.${system};
#        in {
#          default = pkgs.writeShellScriptBin "default-script" ''
#            echo "This is the default package for the flake."
#          '';
#        }
#      );
#
#      defaultPackage = forAllSystems (system: self.packages.${system}.default);
#
#      apps = forAllSystems (system: {
#        default = {
#          type = "app";
#          program = "${self.packages.${system}.default}/bin/default-script";
#        };
#      });
#
#      devShells = forAllSystems (system: {
#        default = mkDevShell system;
#      });
#
#      # Convenience flake checks
#      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
#    };
#}
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

      mkHomeConfiguration = { system, username, hostname, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = [
            ./nix/home-manager/default.nix
            {
              home = {
                inherit username;
                homeDirectory = if system == "aarch64-darwin"
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

      devShells = forAllSystems (system: {
        default = import ./nix/shells/default.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
        base = import ./nix/shells/base.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
        full = import ./nix/shells/full.nix { pkgs = nixpkgsFor.${system}; inherit home-manager system; };
      });

      checks = nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations;
    };
}