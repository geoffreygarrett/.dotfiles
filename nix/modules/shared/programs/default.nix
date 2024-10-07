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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };
  imports = [
    (importModule ./alacritty.nix)
    # (importModule ./zellij.nix)
    (importModule ./git.nix)
    (importModule ./gh.nix)
    (importModule ./tmux.nix)
    (importModule ./zsh.nix)
    (importModule ./bash.nix)
    (importModule ./nushell.nix)
    (importModule ./tms.nix)
    (importModule ./bash.nix)

    #  (importModule ./nvim.nix)
    (importModule ./nixvim/default.nix)
    (importModule ./starship.nix)
    #(importModule ./mdt.nix)
    (importModule ./firefox.nix)
    (importModule ./htop.nix)
    (importModule ./vscode.nix)
  ];

  theme.enable = true;
}
