{
  pkgs,
  ...
}:
{
  xsession.windowManager.bspwm = {
    enable = true;
    settings = {
      border_width = 2;
      window_gap = 10;
      split_ratio = 0.52;
      borderless_monocle = true;
      gapless_monocle = true;
      focus_follows_pointer = true;
      pointer_follows_focus = false;
    };
    startupPrograms = [
      "${pkgs.sxhkd}/bin/sxhkd"
      "${pkgs.autorandr}/bin/autorandr --change"
    ];
    extraConfig = ''
      bspc config normal_border_color "${addOpacity colors.background-alt 0.5}"
      bspc config active_border_color "${addOpacity colors.primary 0.5}"
      bspc config focused_border_color "${addOpacity colors.primary 0.5}"
      bspc config presel_feedback_color "${addOpacity colors.secondary 0.5}"
    '';
  };

  custom.displays.hooks.postswitch = {
    "bspwm-desktops" = ''
      ${pkgs.bspwm}/bin/bspc monitor DP-4 -d 1 2 3 4 5
      ${pkgs.bspwm}/bin/bspc monitor HDMI-1 -d 6 7 8 9 0
      ${pkgs.bspwm}/bin/bspc wm -r
    '';
  };
}
