{ pkgs }:
pkgs.writeShellScriptBin "brightness-control" ''
  set -e

  STEP=5
  MAX_BRIGHTNESS=100
  MIN_BRIGHTNESS=5
  LOCKFILE="/tmp/brightness-lock"
  BRIGHTNESS_FILE="/tmp/brightness-value"

  # Ensure only one instance of the script runs at a time
  if [ -e "$LOCKFILE" ]; then
    exit 0
  fi
  trap 'rm -f "$LOCKFILE"' EXIT
  touch "$LOCKFILE"

  # Use pkgs.xrandr, pkgs.gnugrep, pkgs.coreutils, pkgs.bc from Nix
  XRANDR=${pkgs.xorg.xrandr}/bin/xrandr
  GREP=${pkgs.gnugrep}/bin/grep
  AWK=${pkgs.gawk}/bin/awk
  BC=${pkgs.bc}/bin/bc
  DUNSTIFY=${pkgs.dunst}/bin/dunstify

  # Function to get the current brightness level
  get_brightness() {
    # Read cached brightness value to avoid frequent xrandr calls
    if [ -f "$BRIGHTNESS_FILE" ]; then
      cat "$BRIGHTNESS_FILE"
    else
      current_brightness=$($XRANDR --verbose | $GREP -m 1 -i brightness | $AWK '{print int($2 * 100)}')
      echo "$current_brightness" > "$BRIGHTNESS_FILE"
      echo "$current_brightness"
    fi
  }

  # Function to set the brightness level
  set_brightness() {
    for output in $($XRANDR | $GREP " connected" | cut -f1 -d " "); do
      $XRANDR --output "$output" --brightness $(echo "scale=2; $1 / 100" | $BC)
    done
    # Cache the new brightness value
    echo "$1" > "$BRIGHTNESS_FILE"
  }

  # Function to send a notification and update Polybar with the new brightness level
  notify() {
    brightness=$(get_brightness)
    if [ "$brightness" -ge 80 ]; then
      ramp=" "
    elif [ "$brightness" -ge 60 ]; then
      ramp=" "
    elif [ "$brightness" -ge 40 ]; then
      ramp=" "
    elif [ "$brightness" -ge 20 ]; then
      ramp=" "
    else
      ramp=" "
    fi
    $DUNSTIFY -a "changebrightness" -u low -i display-brightness -h string:x-dunst-stack-tag:brightness \
      -h int:value:"$brightness" "Brightness: $brightness%"

    # Immediately update Polybar with the new brightness level
    echo "$ramp $brightness%" > /tmp/polybar-brightness
    polybar-msg action "#brightness.hook.0"
  }

  # Main case statement for handling brightness controls
  case $1 in
    up)
      new=$(( $(get_brightness) + STEP ))
      [[ $new -gt $MAX_BRIGHTNESS ]] && new=$MAX_BRIGHTNESS
      set_brightness $new
      notify
      ;;
    down)
      new=$(( $(get_brightness) - STEP ))
      [[ $new -lt $MIN_BRIGHTNESS ]] && new=$MIN_BRIGHTNESS
      set_brightness $new
      notify
      ;;
    set)
      if [[ $2 -ge $MIN_BRIGHTNESS && $2 -le $MAX_BRIGHTNESS ]]; then
        set_brightness $2
        notify
      else
        echo "Invalid brightness value. Must be between $MIN_BRIGHTNESS and $MAX_BRIGHTNESS."
        exit 1
      fi
      ;;
    get)
      get_brightness
      ;;
    *)
      echo "Usage: $0 {up|down|set <value>|get}"
      exit 1
      ;;
  esac
''
