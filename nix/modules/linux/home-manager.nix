{
  self,
  config,
  lib,
  pkgs,
  inputs,
  services,
  ...
}:
{
  home.stateVersion = "24.05";
  system.os = "linux";
  imports = [
    ../shared/home-manager/programs/git.nix
    ../shared/home-manager/programs/gh.nix
    ../shared/home-manager/programs/htop.nix
    ../shared/home-manager/programs/nushell.nix
    ../shared/home-manager/programs/alacritty.nix
    ../shared/home-manager/programs/nvim.nix
    ../shared/home-manager/programs/starship.nix
    ../shared/home-manager/programs/zellij.nix
    ../shared/home-manager/programs/zsh.nix
    ../shared/secrets.nix
    ../shared/aliases.nix
  ];
  programs.bash = {
    enable = true;
  };
  home.packages = import ./packages.nix { inherit pkgs; };
}
