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
  # Original image path in the Nix store
  originalWallpaper = ../../../../../modules/shared/assets/wallpaper/nix-wallpaper-binary-black.png;
  # Create a separate script for wallpaper modification
  modifyWallpaper = pkgs.writeShellScriptBin "modify-wallpaper" ''
    #!${pkgs.bash}/bin/bash
    input="$1"
    output="$2"
    ${pkgs.imagemagick}/bin/magick "$input" \
      \( +clone -fill "#${base16.base00}" -colorize 30 \) -composite \
      \( +clone -fill "#${base16.base01}" -colorize 20 \) -composite \
      \( +clone -fill "#${base16.base05}" -colorize 15 \) -composite \
      \( +clone -fill "#${base16.base0D}" -colorize 10 \) -composite \
      -set colorspace sRGB \
      -modulate 100,110,100 \
      -brightness-contrast -3x25 \
      -level 2%,98% \
      "$output"
  ''; # Use the script to modify the wallpaper
  modifiedWallpaper =
    pkgs.runCommand "modified-wallpaper"
      {
        buildInputs = [
          pkgs.imagemagick
          modifyWallpaper
        ];
      }
      ''
        mkdir -p $out
        modify-wallpaper ${originalWallpaper} $out/nix-wallpaper-modified.png
      '';
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
      "${pkgs.autorandr}/bin/autorandr --change"
      "${monitor-setup}/bin/monitor-setup"
      # Add a small delay before running feh
      "${pkgs.coreutils}/bin/sleep 1 && ${pkgs.feh}/bin/feh --bg-fill ${modifiedWallpaper}/nix-wallpaper-modified.png"
    ];
    extraConfig = ''
      bspc config normal_border_color "${addOpacity base16.base01 0.5}"
      bspc config active_border_color "${addOpacity base16.base0D 0.5}"
      bspc config focused_border_color "${addOpacity base16.base0D 0.5}"
      bspc config presel_feedback_color "${addOpacity base16.base0E 0.5}"
    '';
  };
}
