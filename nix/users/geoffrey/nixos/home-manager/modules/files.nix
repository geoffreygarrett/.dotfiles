{ pkgs, ... }:
{
  home.file.".Xresources".text = ''
    ! X11 DPI setting
    Xft.dpi: 96

    ! Font rendering settings
    Xft.antialias: 1
    Xft.hinting: 1
    Xft.rgba: rgb
    Xft.hintstyle: hintslight
    Xft.lcdfilter: lcddefault

    ! Cursor size
    Xcursor.size: 24

  '';
  home.file.".face".source = pkgs.fetchurl {
    url = "https://github.com/geoffreygarrett.png";
    sha256 = "0wjxqfjxlnaql73hf2hvb0nxxy79wryf6wc6c8s880gjm5ghx22p";
  };
}
