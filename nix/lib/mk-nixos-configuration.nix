# lib/mk-nixos-configuration.nix
{ inputs, ... }:
{ system, hostname, users, modules ? [ ] }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../modules/nixos/default.nix
    inputs.home-manager.nixosModules.home-manager
    {
      networking.hostName = hostname;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${users.primary.username} = import ../home/nixos.nix;
    }
  ] ++ modules;
  specialArgs = { inherit inputs; };
}
