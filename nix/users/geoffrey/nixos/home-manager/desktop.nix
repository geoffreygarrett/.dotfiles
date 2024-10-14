{
  pkgs,
  lib,
  config,
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix
    ../../home-manager/desktop.nix

    # Add after this comment
    ./modules/polybar
    ./modules/bspwm.nix
    ./modules/dunst.nix
    ./modules/rofi.nix
    ./modules/skhd.nix
    ./modules/files.nix
    ./modules/picom.nix
    ./modules/sway.nix
    ./modules/theming.nix
  ];

  home.packages = with pkgs; [
    qalculate-qt
    # thunderbird
    mailspring
    gimp
    slack
    inkscape
    vlc
    # blender
  ];
}
