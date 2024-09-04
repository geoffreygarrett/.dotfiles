{ nixpkgs, home-manager, ... }:

let
  forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
  nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
in
{
  mkHomeConfiguration = { system, username, hostname, extraModules ? [ ] }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgsFor.${system};
      modules = [
        ./home/default.nix
        {
          home = {
            inherit username;
            homeDirectory =
              if system == "aarch64-darwin"
              then "/Users/${username}"
              else "/home/${username}";
            stateVersion = "22.11";
          };
        }
      ] ++ extraModules;
      extraSpecialArgs = { inherit system hostname; };
    };
}
