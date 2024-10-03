{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellScriptBin "elgato-light-control" ''
  # Configuration
  ELGATO_PORT="9123"
  MAX_JOBS=100
  KNOWN_LIGHTS_DIR="$HOME/.config/elgato-lights"
  KNOWN_LIGHTS_FILE="$KNOWN_LIGHTS_DIR/known_lights.txt"

  # Ensure the directory for known lights exists
  mkdir -p "$KNOWN_LIGHTS_DIR"

  # Function to get all possible subnets
  get_subnets() {
    ${pkgs.iproute2}/bin/ip -4 addr show | ${pkgs.gawk}/bin/awk '/inet / && !/127.0.0.1/ {
      split($2, a, "/")
      split(a[1], b, ".")
      print b[1] "." b[2] "." b[3]
    }'
  }

  # Check if an Elgato light exists at the given IP
  check_elgato() {
    local ip=$1
    response=$(${pkgs.curl}/bin/curl --silent --max-time 1 --location --request GET "http://$ip:$ELGATO_PORT/elgato/lights" --header 'Content-Type: application/json')
    if [[ $response == *"numberOfLights"* ]]; then
      echo "$ip"
      return 0
    fi
    return 1
  }

  # Manage the number of concurrent jobs
  wait_for_jobs() {
    while [[ $(jobs | ${pkgs.coreutils}/bin/wc -l) -ge $MAX_JOBS ]]; do
      sleep 0.1
    done
  }

  # Scan the local subnets for Elgato devices
  scan_network() {
    local found_devices=()
    mapfile -t subnets < <(get_subnets)
    
    for subnet in "''${subnets[@]}"; do
      echo "Scanning subnet $subnet..." >&2
      for i in {1..254}; do
        wait_for_jobs
        if ip="$(check_elgato "$subnet.$i")" 2>/dev/null; then
          found_devices+=("$ip")
          echo "Found Elgato light at $ip" >&2
        fi &
      done
    done
    wait
    if [ ''${#found_devices[@]} -eq 0 ]; then
      echo "No Elgato lights found." >&2
      exit 1
    fi
    printf '%s\n' "''${found_devices[@]}"
  }

  # Light control functions
  get_light_state() {
    local ip=$1
    ${pkgs.curl}/bin/curl --silent "http://$ip:$ELGATO_PORT/elgato/lights" | ${pkgs.jq}/bin/jq '.lights[0]'
  }

  set_light_state() {
    local ip=$1
    local power=$2
    local brightness=$3
    local temperature=$4
    ${pkgs.curl}/bin/curl --silent --location --request PUT "http://$ip:$ELGATO_PORT/elgato/lights" \
    --header 'Content-Type: application/json' \
    --data "{
        \"lights\": [
            {
                \"on\": $power,
                \"brightness\": $brightness,
                \"temperature\": $temperature
            }
        ]
    }"
  }

  # Show usage
  show_help() {
    echo "Usage: $0 {on|off|inc_bright|dec_bright|inc_temp|dec_temp} [brightness] [temperature]"
    echo "Example: $0 on 50 300"
    echo "         $0 inc_bright"
  }

  # Validate ranges
  validate_range() {
    local value=$1
    local min=$2
    local max=$3
    [[ $value -ge $min && $value -le $max ]] || return 1
  }

  # Handle increment/decrement
  adjust_value() {
    local current=$1
    local adjustment=$2
    local min=$3
    local max=$4
    local new_value=$((current + adjustment))
    [[ $new_value -lt $min ]] && new_value=$min
    [[ $new_value -gt $max ]] && new_value=$max
    echo "$new_value"
  }

  # Main logic
  main() {
    local command=$1
    local brightness=$2
    local temperature=$3

    local known_lights=()
    if [[ -f $KNOWN_LIGHTS_FILE ]]; then
      mapfile -t known_lights < "$KNOWN_LIGHTS_FILE"
    fi

    if [[ ''${#known_lights[@]} -eq 0 ]]; then
      echo "No known lights found. Scanning network for Elgato lights..." >&2
      mapfile -t found_lights < <(scan_network)
      if [[ ''${#found_lights[@]} -eq 0 ]]; then
        echo "No Elgato lights found on the network." >&2
        exit 1
      fi
      known_lights=("''${found_lights[@]}")
      printf '%s\n' "''${known_lights[@]}" > "$KNOWN_LIGHTS_FILE"
      echo "Found lights: ''${known_lights[*]}" >&2
    fi

    local selected_light
    selected_light=$(select_light known_lights) || exit 1

    echo "Controlling light at $selected_light"

    # Fetch current state
    current_state=$(get_light_state $selected_light)
    current_brightness=$(echo "$current_state" | ${pkgs.jq}/bin/jq '.brightness')
    current_temperature=$(echo "$current_state" | ${pkgs.jq}/bin/jq '.temperature')
    current_power=$(echo "$current_state" | ${pkgs.jq}/bin/jq '.on')

    # Process command
    case "$command" in
      on)
        power=1
        ;;
      off)
        power=0
        ;;
      inc_bright)
        brightness=$(adjust_value "$current_brightness" 10 0 100)
        ;;
      dec_bright)
        brightness=$(adjust_value "$current_brightness" -10 0 100)
        ;;
      inc_temp)
        temperature=$(adjust_value "$current_temperature" 10 143 344)
        ;;
      dec_temp)
        temperature=$(adjust_value "$current_temperature" -10 143 344)
        ;;
      *)
        show_help
        exit 1
        ;;
    esac

    # Use provided values or defaults
    power=''${power:-$current_power}
    brightness=''${brightness:-$current_brightness}
    temperature=''${temperature:-$current_temperature}

    # Validate brightness and temperature
    validate_range "$brightness" 0 100 || { echo "Brightness should be between 0 and 100."; exit 1; }
    validate_range "$temperature" 143 344 || { echo "Temperature should be between 143 and 344."; exit 1; }

    # Apply settings to the lamp
    set_light_state "$selected_light" "$power" "$brightness" "$temperature"
    echo "Elgato light set to: Power=$power, Brightness=$brightness, Temperature=$temperature"
  }

  # Run the main function
  main "$@"
''
