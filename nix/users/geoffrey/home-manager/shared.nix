{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  username = "geoffrey";
in
{
  imports = [
    # Don't change
    inputs.nix-colors.homeManagerModules.default

    # Add after this comment
    ./modules/gh.nix
    ./modules/git.nix
    ./modules/tms.nix
    ./modules/starship.nix
    ./modules/nushell.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/htop.nix
  ];

  colorScheme = import ../shared/nix-colors.nix;

  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
    );
    stateVersion = lib.mkDefault "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
