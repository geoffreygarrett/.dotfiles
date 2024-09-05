{ config, lib, pkgs, ... }:
{
  home.stateVersion = "22.11";
  imports = [
    ./alacritty.nix
    ./zellij.nix
    ./git.nix
    ./gh.nix
    ./packages.nix
    ./zsh.nix
    ./nushell.nix
    ./nvim.nix
    ./starship.nix
  ];
  fonts.fontconfig.enable = true;

  # Add these packages to ensure OpenGL and GLX are installed
  home.packages = with pkgs;
    [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
}
