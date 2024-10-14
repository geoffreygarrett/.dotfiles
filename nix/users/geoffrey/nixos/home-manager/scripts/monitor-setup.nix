{ pkgs, ... }:
pkgs.writeShellScriptBin "monitor-setup" ''
  # Restart Polybar
  # ${pkgs.procps}/bin/pkill polybar
  # ${pkgs.polybar}/bin/polybar main-left &
  # ${pkgs.polybar}/bin/polybar main-right &
  # launch_if_not_open() {
  #   local app=$1
  #
  #   if ! pgrep -x $app; then
  #     $app &
  #   fi
  # }
  #
  # launch_if_not_open alacritty
  # launch_if_not_open firefox
  # launch_if_not_open spotify


  # # Function to launch app and fullscreen it
  # launch_and_fullscreen() {
  #   local app=$1
  #   local class=$2
  #   local desktop=$3
  #
  #   # Launch the application if it's not running
  #   if ! pgrep -x $app; then
  #     $app &
  #   fi
  #
  #   # Subscribe to the window event instead of polling
  #   bspc subscribe node_add | while read -r _ _ wid; do
  #     if bspc query -N -n $wid | grep -q "$class"; then
  #       bspc node "$wid" -d $desktop
  #       bspc node "$wid" -t fullscreen
  #       break
  #     fi
  #   done &
  # }
  #
  # # Launch and fullscreen applications
  # launch_and_fullscreen "${pkgs.alacritty}/bin/alacritty" Alacritty 1
  # launch_and_fullscreen "${pkgs.firefox}/bin/firefox" firefox 2
  # launch_and_fullscreen "${pkgs.spotify}/bin/spotify" Spotify 3

  # Ensure the first desktop is focused at the end
  ${pkgs.bspwm}/bin/bspc desktop '^1' --focus


''
