# gnome.nix
{ config, pkgs, ... }:

let
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
  imports = [ ./common.nix ];

  services.xserver = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
        settings = {
          "org/gnome/desktop/background" = {
            picture-uri = "file:///etc/login-wallpaper.png";
            picture-uri-dark = "file:///etc/login-wallpaper.png";
            picture-options = "spanned";
            primary-color = "#000000";
          };
        };
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
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [ firefox ];
}
