{

  pkgs,
  ...
}:

let
  fingerprints = builtins.fromJSON (builtins.readFile ./fingerprint.json);
in
{
  imports = [ ../../../../modules/nixos/displays.nix ];
  custom.displays = {
    enable = true;
    monitors = {
      "HDMI-1" = {
        fingerprint = fingerprints."HDMI-1";
        enable = true;
        mode = "3840x2160";
        rate = "59.94";
        primary = false;
        position = "0x0";
        scale = {
          x = 1.0;
          y = 1.0;
        };
        rotate = "normal";
      };
      "DP-4" = {
        fingerprint = fingerprints."DP-4";
        enable = true;
        mode = "2560x1440";
        rate = "143.97";
        primary = true;
        position = "3840x720";
        scale = {
          x = 1.0;
          y = 1.0;
        };
        rotate = "normal";
      };
    };
    hooks = {
      postswitch = {
        "notify-wm" = ''
          ${pkgs.libnotify}/bin/notify-send "Display profile changed"
        '';
        "restart-polybar" = ''
          ${pkgs.systemd}/bin/systemctl --user restart polybar
        '';
      };
    };
  };
}
