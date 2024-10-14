{ pkgs }:
pkgs.writeShellScriptBin "brightness-control" ''
  set -e
  STEP=5
  MAX_BRIGHTNESS=100
  MIN_BRIGHTNESS=5
  LOCKFILE="$HOME/.brightness-lock"
  BRIGHTNESS_FILE="$HOME/.brightness-values"
  OFFSET_FILE="$HOME/.brightness-offsets"
  POLYBAR_BRIGHTNESS_FILE="$HOME/.polybar-brightness"
  DEBUG_FILE="$HOME/.brightness-control-debug.log"

  # Debugging function
  debug() {
    echo "$(date): $1" >> "$DEBUG_FILE"
  }

  debug "Script started with arguments: $@"

  # Ensure only one instance of the script runs at a time
  if [ -e "$LOCKFILE" ]; then
    debug "Script is already running. Exiting."
    exit 0
  fi
  trap 'rm -f "$LOCKFILE"; debug "Script finished."' EXIT
  touch "$LOCKFILE"

  # Use pkgs.xrandr, pkgs.gnugrep, pkgs.coreutils, pkgs.bc from Nix
  XRANDR=${pkgs.xorg.xrandr}/bin/xrandr
  GREP=${pkgs.gnugrep}/bin/grep
  AWK=${pkgs.gawk}/bin/awk
  BC=${pkgs.bc}/bin/bc
  DUNSTIFY=${pkgs.dunst}/bin/dunstify

  # Function to get the current brightness level for all monitors
  get_brightness() {
    debug "Getting brightness"
    if [ -f "$BRIGHTNESS_FILE" ]; then
      debug "Reading brightness from file"
      cat "$BRIGHTNESS_FILE"
    else
      debug "Querying xrandr for brightness"
      $XRANDR --verbose | $GREP -i "brightness:" | $AWK '{print $1 " " int($2 * 100)}' > "$BRIGHTNESS_FILE"
      cat "$BRIGHTNESS_FILE"
    fi
  }

  # Function to set the brightness level for all monitors
  set_brightness() {
    local new_brightness=$1
    local offsets=$([ -f "$OFFSET_FILE" ] && cat "$OFFSET_FILE" || echo "")
    
    debug "Setting brightness to $new_brightness"
    
    $XRANDR | $GREP " connected" | cut -f1 -d " " | while read -r output; do
      debug "Adjusting brightness for output: $output"
      local offset=$(echo "$offsets" | $GREP "^$output " | $AWK '{print $2}')
      [ -z "$offset" ] && offset=0
      
      local adjusted_brightness=$(echo "$new_brightness + $offset" | $BC)
      [ $adjusted_brightness -gt $MAX_BRIGHTNESS ] && adjusted_brightness=$MAX_BRIGHTNESS
      [ $adjusted_brightness -lt $MIN_BRIGHTNESS ] && adjusted_brightness=$MIN_BRIGHTNESS
      
      debug "Adjusted brightness for $output: $adjusted_brightness"
      
      if ! $XRANDR --output "$output" --brightness $(echo "scale=2; $adjusted_brightness / 100" | $BC); then
        debug "Failed to set brightness for $output"
      fi
      echo "$output $adjusted_brightness" >> "$BRIGHTNESS_FILE.tmp"
    done
    
    mv "$BRIGHTNESS_FILE.tmp" "$BRIGHTNESS_FILE"
  }

  # Function to set offset for a specific monitor
  set_offset() {
    local output=$1
    local offset=$2
    
    debug "Setting offset $offset for output $output"
    
    if [ -f "$OFFSET_FILE" ]; then
      $GREP -v "^$output " "$OFFSET_FILE" > "$OFFSET_FILE.tmp"
      echo "$output $offset" >> "$OFFSET_FILE.tmp"
      mv "$OFFSET_FILE.tmp" "$OFFSET_FILE"
    else
      echo "$output $offset" > "$OFFSET_FILE"
    fi
  }

  # Function to send a notification and update Polybar with the new brightness level
  notify() {
    local total_brightness=0
    local count=0
    
    debug "Calculating average brightness"
    
    while read -r output brightness; do
      total_brightness=$((total_brightness + brightness))
      count=$((count + 1))
    done < <(get_brightness)
    
    local avg_brightness=$((total_brightness / count))
    
    debug "Average brightness: $avg_brightness"
    
    if [ "$avg_brightness" -ge 80 ]; then
      ramp=" "
    elif [ "$avg_brightness" -ge 60 ]; then
      ramp=" "
    elif [ "$avg_brightness" -ge 40 ]; then
      ramp=" "
    elif [ "$avg_brightness" -ge 20 ]; then
      ramp=" "
    else
      ramp=" "
    fi
    
    $DUNSTIFY -a "changebrightness" -u low -i display-brightness -h string:x-dunst-stack-tag:brightness \
      -h int:value:"$avg_brightness" "Brightness: $avg_brightness%"
    
    # Immediately update Polybar with the new brightness level
    echo "$ramp $avg_brightness%" > "$POLYBAR_BRIGHTNESS_FILE"
    polybar-msg action "#brightness.hook.0"
  }

  # Main case statement for handling brightness controls
  case $1 in
    up)
      debug "Increasing brightness"
      new=$(( $(get_brightness | $AWK '{sum+=$2} END {print int(sum/NR)}') + STEP ))
      [[ $new -gt $MAX_BRIGHTNESS ]] && new=$MAX_BRIGHTNESS
      set_brightness $new
      notify
      ;;
    down)
      debug "Decreasing brightness"
      new=$(( $(get_brightness | $AWK '{sum+=$2} END {print int(sum/NR)}') - STEP ))
      [[ $new -lt $MIN_BRIGHTNESS ]] && new=$MIN_BRIGHTNESS
      set_brightness $new
      notify
      ;;
    set)
      if [[ $2 -ge $MIN_BRIGHTNESS && $2 -le $MAX_BRIGHTNESS ]]; then
        debug "Setting brightness to $2"
        set_brightness $2
        notify
      else
        debug "Invalid brightness value: $2"
        echo "Invalid brightness value. Must be between $MIN_BRIGHTNESS and $MAX_BRIGHTNESS."
        exit 1
      fi
      ;;
    get)
      debug "Getting current brightness"
      get_brightness
      ;;
    offset)
      if [ $# -eq 3 ]; then
        debug "Setting offset $3 for output $2"
        set_offset $2 $3
        echo "Offset for $2 set to $3"
      else
        debug "Invalid offset command"
        echo "Usage: $0 offset <output> <value>"
        exit 1
      fi
      ;;
    *)
      debug "Invalid command: $1"
      echo "Usage: $0 {up|down|set <value>|get|offset <output> <value>}"
      exit 1
      ;;
  esac
''
