{ config, lib, pkgs, inputs, ... }: {
  home.stateVersion = "22.11";
  imports = [
    ./alacritty.nix
    ./zellij.nix
    ./git.nix
    ./gh.nix
    ./zsh.nix
    ./nushell.nix
    ./nvim.nix
    ./starship.nix
    ./firefox.nix
    inputs.sops-nix.homeManagerModules.sops
  ];
  fonts.fontconfig.enable = true;
  programs.alacritty.enable = true;
  programs.zellij.enable = true;
  programs.git.enable = true;
  programs.gh.enable = true;
  programs.zsh.enable = true;
  programs.nushell.enable = true;
  programs.neovim.enable = true;
  programs.firefox.enable = true;
  programs.starship.enable = true;
}
