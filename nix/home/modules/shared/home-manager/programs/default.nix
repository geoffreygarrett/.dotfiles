{ config, lib, pkgs, inputs, ... }:

let
  # Helper function to import modules with arguments
  importModule = file: import file { inherit config lib pkgs inputs; };
in
{

  imports = [
    (importModule ./alacritty.nix)
    (importModule ./zellij.nix)
    (importModule ./git.nix)
    (importModule ./gh.nix)
    (importModule ./zsh.nix)
    (importModule ./nushell.nix)
    (importModule ./nvim.nix)
    (importModule ./starship.nix)
    (importModule ./qemu.nix)
  ];

  programs = {
    alacritty.enable = true;
    zellij.enable = true;
    git.enable = true;
    gh.enable = true;
    zsh.enable = true;
    nushell.enable = true;
    qemu.enable = true;
    neovim.enable = true;
    starship.enable = true;
  };
}
