{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Color scheme and opacity
  base16 = config.colorScheme.palette;
  addOpacity =
    color: opacity:
    let
      rgb = builtins.substring 1 6 color;
      alpha = builtins.toString (builtins.floor (255 * opacity));
    in
    "#${rgb}${alpha}";

  # Wallpaper generation
  wallpaperGenerator =
    import ../../../../../modules/shared/assets/wallpaper/nixos-wallpaper-generator.nix
      { inherit lib pkgs; };
  generatedWallpaper = wallpaperGenerator { base16theme = base16; };
  setWallpaper = pkgs.writeShellScript "set-wallpaper" ''
    ${pkgs.feh}/bin/feh --bg-fill ${generatedWallpaper}
  '';

  # Import monitor-setup script
  monitor-setup = import ../scripts/monitor-setup.nix { inherit pkgs; };

in
{
  xsession.windowManager.bspwm = {
    enable = true;

    # Basic settings
    settings = {
      border_width = 2;
      window_gap = 10;
      split_ratio = 0.52;
      borderless_monocle = true;
      gapless_monocle = true;
      focus_follows_pointer = true;
      pointer_follows_focus = false;
    };

    # Startup programs
    startupPrograms = [
      "${pkgs.sxhkd}/bin/sxhkd"
      "${pkgs.autorandr}/bin/autorandr --change"
      "sleep 1 && ${pkgs.bspwm}/bin/bspc wm -O DP-4 DP-0"
      "sleep 1 && ${setWallpaper}"
      "sleep 2 && ${pkgs.obsidian}/bin/obsidian"
      "sleep 2 && ${pkgs.alacritty}/bin/alacritty"
      "sleep 2 && ${pkgs.spotify}/bin/spotify"
      "sleep 2 && ${pkgs.firefox}/bin/firefox"
    ];

    # Additional configuration
    extraConfig = ''
      # Window rules
      bspc rule -a obsidian desktop='^1' -o
      bspc rule -a Alacritty desktop='^2' -o
      bspc rule -a firefox desktop='^3' -o
      bspc rule -a Spotify desktop='^4' -o

      # Border colors
      bspc config normal_border_color "${addOpacity base16.base01 0.5}"
      bspc config active_border_color "${addOpacity base16.base0D 0.5}"
      bspc config focused_border_color "${addOpacity base16.base0D 0.5}"
      bspc config presel_feedback_color "${addOpacity base16.base0E 0.5}"
    '';
  };
}
