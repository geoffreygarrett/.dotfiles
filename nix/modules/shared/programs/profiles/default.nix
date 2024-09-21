{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Helper function to import modules with consistent arguments
  importModule =
    file:
    import file {
      inherit
        config
        lib
        pkgs
        inputs
        ;
    };

  # List of modules to import
  modules = [
    ../alacritty.nix
    ../zellij.nix
    ../git.nix
    ../gh.nix
    ../zsh.nix
    ../bash.nix
    ../nushell.nix
    ../nvim.nix
    ../starship.nix
    ../htop.nix
    ../gdk.nix
  ];
in
{
  # Use map to apply importModule to all modules
  imports = map importModule modules;
}
