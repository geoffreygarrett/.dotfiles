# lib/mk-home-configuration.nix
{ inputs, ... }:
{ system, username, userConfig, modules ? [ ] }:

inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  modules = [
    inputs.sops-nix.homeManagerModules.sops
    ../modules/home-manager/default.nix
    {
      home = {
        inherit username;
        homeDirectory =
          if inputs.nixpkgs.stdenv.isDarwin then
            "/Users/${username}"
          else
            "/home/${username}";
      };
      home.stateVersion = "22.11";
    }
    (import ../home/shared.nix { inherit userConfig; })
  ] ++ modules;
  extraSpecialArgs = { inherit inputs; };
}
