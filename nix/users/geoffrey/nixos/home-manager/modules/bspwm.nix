{
  config,
  pkgs,
  ...
}:

let
  base16 = config.colorScheme.palette;

  # Helper function to add opacity to a color
  addOpacity =
    color: opacity:
    let
      rgb = builtins.substring 1 6 color;
      alpha = builtins.toString (builtins.floor (255 * opacity));
    in
    "#${rgb}${alpha}";

  # Import monitor-setup script (adjust the path as necessary)
  monitor-setup = import ../scripts/monitor-setup.nix { inherit pkgs; };

in
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
      "${monitor-setup}/bin/monitor-setup"
      "${pkgs.autorandr}/bin/autorandr --change"
    ];
    extraConfig = ''
      bspc config normal_border_color "${addOpacity base16.base01 0.5}"
      bspc config active_border_color "${addOpacity base16.base0D 0.5}"
      bspc config focused_border_color "${addOpacity base16.base0D 0.5}"
      bspc config presel_feedback_color "${addOpacity base16.base0E 0.5}"
    '';
  };
}
