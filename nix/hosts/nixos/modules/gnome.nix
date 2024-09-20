{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktopEnvironment.gnome;
  screens = [
    {
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
    }
    {
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
    }
  ];
in
{
  options.desktopEnvironment.gnome = {
    enable = mkEnableOption "GNOME desktop environment";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        sessionCommands = ''
          ${builtins.concatStringsSep "\n" (
            builtins.map (
              s:
              "${pkgs.xorg.xrandr}/bin/xrandr --output ${s.output} --mode ${s.mode} --rate ${s.rate} ${
                if s.primary then "--primary" else ""
              }"
            ) screens
          )}
          ${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}
        '';
      };
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface]
          color-scheme='prefer-dark'
          gtk-theme='Adwaita-dark'

          [org.gnome.desktop.background]
          picture-uri='file:///etc/login-wallpaper.png'
          picture-uri-dark='file:///etc/login-wallpaper.png'
          picture-options='spanned'
          primary-color='#000000'
        '';
      };
    };

    environment.systemPackages = with pkgs; [ firefox ];

    # Force Gtk applications to use dark theme
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };

    # Set dark theme for Qt applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
