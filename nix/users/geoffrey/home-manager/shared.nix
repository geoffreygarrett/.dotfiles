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

  colorScheme = {
    slug = "deep-ocean-material";
    name = "Deep Ocean Material";
    author = "Material Theme";
    palette = {
      base00 = "0F111A"; # Background
      base01 = "181A1F"; # Second Background
      base02 = "1F2233"; # Highlight
      base03 = "4B526D"; # Text
      base04 = "8F93A2"; # Foreground
      base05 = "EEFFFF"; # White/Black Color
      base06 = "717CB4"; # Gray Color
      base07 = "FFFFFF"; # Selection Foreground
      base08 = "F07178"; # Red Color
      base09 = "F78C6C"; # Orange Color
      base0A = "FFCB6B"; # Yellow Color
      base0B = "C3E88D"; # Green Color
      base0C = "89DDFF"; # Cyan Color
      base0D = "82AAFF"; # Blue Color
      base0E = "C792EA"; # Purple Color
      base0F = "FF5370"; # Error Color
    };
  };

  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
    );
    stateVersion = lib.mkDefault "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = lib.mkDefault true;
}
