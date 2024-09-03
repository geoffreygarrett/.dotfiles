{ config, lib, pkgs, ... }:
{
  home.stateVersion = "22.11";
  imports = [
    ./alacritty.nix
    ./zellij.nix
    ./git.nix
    ./packages.nix
    ./zsh.nix
    ./nushell.nix
    ./nvim.nix
    ./starship.nix
  ];

  # Uncomment and adjust if you're using sops-nix for secret management
  # sops = {
  #   age.keyFile = "/home/senoraraton/.config/sops/age/keys.txt";
  #   defaultSopsFile = ../secrets/secrets.yaml;
  # };

  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
