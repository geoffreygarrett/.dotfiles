{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    roboto
    dejavu_fonts
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
