{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Helper function to import modules with arguments
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
in
{
  # Import modules that each manage their own program configurations
  imports = [
    (importModule ./alacritty.nix)
    (importModule ./zellij.nix)
    (importModule ./git.nix)
    (importModule ./gh.nix)
    (importModule ./zsh.nix)
    (importModule ./nushell.nix)
    (importModule ./nvim.nix)
    #    (importModule ./starship.nix)
    (importModule ./qemu.nix)
  ];
}
