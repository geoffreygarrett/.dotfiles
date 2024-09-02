{ config, lib, pkgs, ... }:

let
  configDir = ../../config; # This path points to your actual config directory

  # Function to load and map files to their respective content
  loadConfigFiles = dir: builtins.listToAttrs (
    map
      (file: {
        name = ".config/" + lib.removePrefix (toString dir + "/") (toString file);
        source = file;
      })
      (pkgs.lib.filesystem.listFilesRecursive dir)
  );

  # Load all configuration files from the config directory
  configs = loadConfigFiles configDir;

in
{
  home.stateVersion = "22.11";
  imports = [
    ./alacritty.nix
    ./zellij.nix
    ./git.nix
    ./packages.nix
    ./zsh.nix
    ./nvim.nix
  ];

  # Map files from your configDir to ~/.config/
  home.file = configs;

  # Uncomment and adjust if you're using sops-nix for secret management
  # sops = {
  #   age.keyFile = "/home/senoraraton/.config/sops/age/keys.txt";
  #   defaultSopsFile = ../secrets/secrets.yaml;
  # };
}
