{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./services.nix
    ./security.nix
    ./users.nix
    ./packages.nix
    ./fonts.nix
    ./hardware.nix
    ./system.nix
  ];
}
