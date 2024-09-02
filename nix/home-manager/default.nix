{ config, lib, pkgs, ... }:

let
#  configLoader = import ../lib/config-loader.nix { inherit lib pkgs; };
#  configDir = ../../config;
#  configs = configLoader.loadConfigs configDir;
in
{
  home.stateVersion = "22.11";
  imports = [
    ./alacritty.nix
    ./zellij.nix
#    ./cargo.nix
    ./git.nix
    ./packages.nix
    ./zsh.nix
    ./nushell.nix
    ./nvim.nix
    ./starship.nix
  ];

  # Map files from your configDir to ~/.config/
#  home.file = configs;



  # Uncomment and adjust if you're using sops-nix for secret management
  # sops = {
  #   age.keyFile = "/home/senoraraton/.config/sops/age/keys.txt";
  #   defaultSopsFile = ../secrets/secrets.yaml;
  # };
}
