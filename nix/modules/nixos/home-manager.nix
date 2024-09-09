{ config, pkgs, lib, home-manager, inputs, user, ... }:
let
  shared-programs = import ../shared/home-manager.nix {
    inherit config pkgs lib home-manager inputs;
  };
  secrets = import ./secrets.nix { inherit config pkgs user; };
in
{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  imports = [
    shared-programs
    secrets
  ]; # programs = shared-programs // { gpg.enable = true; };
  home.packages = pkgs.callPackage ./packages.nix { inherit pkgs; };
}
