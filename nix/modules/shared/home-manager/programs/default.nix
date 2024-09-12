{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
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
  imports = [
    (importModule ./alacritty.nix)
    (importModule ./zellij.nix)
    (importModule ./git.nix)
    (importModule ./gh.nix)
    (importModule ./zsh.nix)
    (importModule ./bash.nix)
    (importModule ./nushell.nix)
    (importModule ./nvim.nix)
    (importModule ./starship.nix)
    (importModule ./htop.nix)
  ];
}
