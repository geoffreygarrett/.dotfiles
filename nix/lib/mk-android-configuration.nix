# lib/mk-android-configuration.nix
{ nixpkgs, nix-on-droid, ... }:

{ system ? "aarch64-linux", username, extraModules ? [ ] }:

nix-on-droid.lib.nixOnDroidConfiguration {
  pkgs = import nixpkgs { inherit system; };
  modules = [
    ({ config, pkgs, ... }: {
      user.name = username;
      environment.packages = with pkgs; [
        # Add your default packages here
        vim
        git
      ];
      # Add your default Nix-on-Droid configuration here
      system.stateVersion = "24.05";
    })
  ] ++ extraModules;
}
