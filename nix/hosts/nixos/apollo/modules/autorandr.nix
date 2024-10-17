{ pkgs, lib, ... }:
let
  monitorConfig = {
    "DP-0" = {
      enable = true;
      mode = "3840x2160";
      rate = "59.94";
      position = "0x0";
      dpi = 140;
    };
    "DP-4" = {
      enable = true;
      mode = "2560x1440";
      rate = "143.97";
      position = "640x2160";
      primary = true;
      dpi = 109;
    };
  };
  minDpi = builtins.foldl' (
    min: monitor: if monitor.enable && (monitor.dpi < min || min == 0) then monitor.dpi else min
  ) 0 (builtins.attrValues monitorConfig);
  getPrimaryMonitor =
    config: lib.head (lib.attrNames (lib.filterAttrs (name: value: value.primary or false) config));

  getSecondaryMonitor =
    config:
    lib.head (
      lib.attrNames (lib.filterAttrs (name: value: !(value.primary or false) && value.enable) config)
    );

  primaryMonitor = getPrimaryMonitor monitorConfig;
  secondaryMonitor = getSecondaryMonitor monitorConfig;
  configureBspwm = pkgs.writeShellScriptBin "configure-bspwm" ''
    connected_monitors=$(${pkgs.xorg.xrandr}/bin/xrandr -q | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.coreutils}/bin/cut -d ' ' -f1)

    if echo "$connected_monitors" | ${pkgs.gnugrep}/bin/grep -q "${primaryMonitor}"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output "${primaryMonitor}" \
        --mode "${monitorConfig.${primaryMonitor}.mode}" \
        --rate "${monitorConfig.${primaryMonitor}.rate}" \
        --pos "${monitorConfig.${primaryMonitor}.position}" \
        --primary
    fi

    if echo "$connected_monitors" | ${pkgs.gnugrep}/bin/grep -q "${secondaryMonitor}"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output "${secondaryMonitor}" \
        --mode "${monitorConfig.${secondaryMonitor}.mode}" \
        --rate "${monitorConfig.${secondaryMonitor}.rate}" \
        --pos "${monitorConfig.${secondaryMonitor}.position}"
      
      ${pkgs.bspwm}/bin/bspc monitor ${primaryMonitor} -d 1 2 3
      ${pkgs.bspwm}/bin/bspc monitor ${secondaryMonitor} -d 4 5 6
    else
      ${pkgs.bspwm}/bin/bspc monitor ${primaryMonitor} -d 1 2 3 4 5 6
    fi

    ${pkgs.bspwm}/bin/bspc wm -O ${primaryMonitor} ${secondaryMonitor}
  '';
in
{
  services.autorandr = {
    enable = true;
    defaultTarget = "default";
    profiles.default = {
      fingerprint = builtins.fromJSON (builtins.readFile ./fingerprint.json);
      config = monitorConfig;
    };
    hooks = {
      postswitch = {
        "configure-bspwm" = "${configureBspwm}/bin/configure-bspwm";
        "restart-polybar" = "${pkgs.systemd}/bin/systemctl --user restart polybar";
      };
    };
  };
  environment.systemPackages = with pkgs; [
    xorg.xrandr
    bspwm
    autorandr
    configureBspwm
  ];
  environment.etc."X11/Xresources".text = ''
    Xft.dpi: ${toString minDpi}
  '';
}
