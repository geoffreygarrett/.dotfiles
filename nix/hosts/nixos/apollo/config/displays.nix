{

  pkgs,
  ...
}:

let
  fingerprints = {
    "DP-4" = "00ffffffffffff0006b32227010101010b1f0104b53c22783b9e20a8554ca0260e5054bfef00714f81809500d1c00101010101010101565e00a0a0a029503020350055502100001c000000fd003090e6e63c010a202020202020000000fc0056473237410a20202020202020000000ff004d334c4d51533132353838370a01b8020329f14e90111213040e0f1d1e1f1405403f2309070783010000e305e001e6060701737300e2006a59e7006aa0a067501520350055502100001a6fc200a0a0a055503020350055502100001a5aa000a0a0a046503020350055502100001a000000000000000000000000000000000000000000000000000000000000000032";
    "HDMI-1" = "00ffffffffffff0010aca3424c3331372120010380462778eabac5a9534ea6250e5054a54b00e1c0d100d1c0b300a94081808100714f4dd000a0f0703e8030203500b9882100001a000000ff004a345157584e330a2020202020000000fc0044454c4c20503332323351450a000000fd00184b1e8c3c000a202020202020014702032ab14e61605f101f0514041312110302016b030c001000383c2000200167d85dc401788003e20f03a36600a0f0703e8030203500b9882100001a565e00a0a0a0295030203500b9882100001a114400a08000255030203600b9882100001a00000000000000000000000000000000000000000000000000000000000000d9";
  };
in
{
  imports = [ ../../../../modules/nixos/displays.nix ];

  custom.displays = {
    enable = true;
    monitors = {
      "DP-4" = {
        fingerprint = fingerprints."DP-4";
        enable = true;
        mode = "2560x1440";
        rate = "143.97";
        primary = true;
        position = "0x0";
        scale = {
          method = "factor";
          x = 1.0;
          y = 1.0;
        };
      };
      "HDMI-1" = {
        fingerprint = fingerprints."HDMI-1";
        enable = true;
        mode = "3840x2160";
        rate = "59.94";
        primary = false;
        position = "2560x0";
        scale = {
          method = "factor";
          x = 1.0;
          y = 1.0;
        };
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
