# lib/mk-darwin-configuration.nix
{ inputs, ... }:
{ system, hostname, user, modules ? [ ] }:

inputs.nix-darwin.lib.darwinSystem {
  inherit system;
  modules = [
    #    ../modules/darwin/default.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    #    inputs.sops-nix.homeManagerModules.sops
    {
      networking.hostName = hostname;
      nix-homebrew = {
        enable = true;
        user = user;
        #        user = user;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import ../home/artemis.nix;
    }

  ] ++ modules;
  specialArgs = { inherit inputs; };
}
