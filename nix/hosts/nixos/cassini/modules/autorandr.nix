{ pkgs, ... }:
let
  monitorConfig = {
    "eDP-1" = {
      enable = true;
      mode = "3840x2160";
      rate = "59.94";
      primary = true;
      position = "3840x0";
    };
    "DP-1" = {
      enable = true;
      mode = "3840x2160";
      rate = "59.94";
      position = "0x0";
    };
  };
  configureBspwm = pkgs.writeShellScript "configure-bspwm" ''
    log_file="/tmp/monitor_setup.log"
    echo "Monitor setup triggered at $(date)" > $log_file

    connected=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.coreutils}/bin/cut -d ' ' -f1)
    count=$(echo "$connected" | ${pkgs.coreutils}/bin/wc -l)
    echo "Connected monitors: $count" >> $log_file
    echo "Connected outputs: $connected" >> $log_file

    if [ "$count" -eq 1 ]; then
      echo "Single monitor setup" >> $log_file
      ${pkgs.bspwm}/bin/bspc monitor $connected -d 1 2 3 4 5 6
      echo "Workspaces 1-6 assigned to $connected" >> $log_file
    elif [ "$count" -eq 2 ]; then
      echo "Dual monitor setup" >> $log_file
      primary=$(echo "$connected" | ${pkgs.gnugrep}/bin/grep -E "eDP-0")
      secondary=$(echo "$connected" | ${pkgs.gnugrep}/bin/grep -vE "eDP-0")
      ${pkgs.bspwm}/bin/bspc monitor $primary -d 1 2 3
      ${pkgs.bspwm}/bin/bspc monitor $secondary -d 4 5 6
      ${pkgs.bspwm}/bin/bspc wm -O $primary $secondary
      echo "Primary: $primary" >> $log_file
      echo "Secondary: $secondary" >> $log_file
      echo "Workspaces 1-3 assigned to $primary" >> $log_file
      echo "Workspaces 4-6 assigned to $secondary" >> $log_file
    fi

    echo "Monitor setup completed at $(date)" >> $log_file
  '';
in
{
  services.autorandr = {
    enable = true;
    defaultTarget = "flexible-setup";
    profiles.flexible-setup = {
      # fingerprint = builtins.fromJSON (builtins.readFile ./fingerprint.json);
      config = monitorConfig;
    };
    hooks.postswitch = {
      "restart-polybar" = "${pkgs.systemd}/bin/systemctl --user restart polybar";
      "configure-bspwm" = "${configureBspwm}";
    };
  };
  environment.systemPackages = with pkgs; [
    xorg.xrandr
    bspwm
    autorandr
  ];
}
