# Theming for gnome, gtk and qt.
{
  pkgs,
  ...
}:

{
  programs.dconf.enable = true;

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };

  services.flatpak.enable = true;

  # Enable XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Lightdm
  services.xserver.displayManager.lightdm.greeters.slick = {
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
    };
    font = {
      name = "Cantarell 11";
      package = pkgs.cantarell-fonts;
    };
    extraConfig = ''
      draw-user-backgrounds=true
      activate-numlock=true
    '';
  };
}
