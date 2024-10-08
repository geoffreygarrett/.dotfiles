{
  pkgs,
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix

    # Add after this comment
    ./modules/polybar
    ./modules/bspwm.nix
    ./modules/dunst.nix
    ./modules/rofi.nix
    ./modules/skhd.nix
    ./modules/files.nix
    ./modules/picom.nix
    ./modules/sway.nix
  ] ++ (import ../../home-manager/desktop.nix args).imports;
}
