{ config, lib, pkgs, ... }:

let
  configDir = ../../config; # Adjust this path to point to your actual config directory
in
{
  home.stateVersion = "22.11";
  imports = [
    ./alarritty.nix
    ./git.nix
    ./packages.nix
    ./zsh.nix
    # ... other imports ...
  ];

  # Map files from your configDir to ~/.config/
  home.file = builtins.listToAttrs (
    map
      (file: {
        name = ".config/" + lib.removePrefix (toString configDir + "/") (toString file);
        value = { source = file; };
      })
      (pkgs.lib.filesystem.listFilesRecursive configDir)
  );

  # Uncomment and adjust if you're using sops-nix for secret management
  # sops = {
  #   age.keyFile = "/home/senoraraton/.config/sops/age/keys.txt";
  #   defaultSopsFile = ../secrets/secrets.yaml;
  # };
}
