{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./modules/polybar
    ./modules/bspwm.nix
    ./modules/dunst.nix
    ./modules/rofi.nix
    ./modules/skhd.nix
    ./modules/files.nix
    ./modules/picom.nix
  ];
  colorScheme = import ../../shared/nix-colors.nix;
}
