#!/bin/bas
#!/bin/bash

# Elgato lamp IP and port
ELGATO_IP="192.168.68.113"
ELGATO_PORT="9123"
URL="http://$ELGATO_IP:$ELGATO_PORT/elgato/lights"

# Fetch current light state
get_light_state() {
    curl --silent "$URL" | jq '.lights[0]'
}

# Control the lamp
set_light_state() {
    local power=$1    # 1 = on, 0 = off
    local brightness=$2  # Brightness level (0-100)
    local temperature=$3  # Color temperature (143-344)

    curl --silent --location --request PUT "$URL" \
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

# Parse arguments and control light
if [[ $# -lt 1 || $# -gt 3 ]]; then
    show_help
    exit 1
fi

# Fetch current state
current_state=$(get_light_state)
current_brightness=$(echo "$current_state" | jq '.brightness')
current_temperature=$(echo "$current_state" | jq '.temperature')
current_power=$(echo "$current_state" | jq '.on')

power=$current_power
brightness=$current_brightness
temperature=$current_temperature

case "$1" in
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

# Override with user inputs if provided
brightness=${2:-$brightness}
temperature=${3:-$temperature}

# Validate brightness and temperature
validate_range "$brightness" 0 100 || { echo "Brightness should be between 0 and 100."; exit 1; }
validate_range "$temperature" 143 344 || { echo "Temperature should be between 143 and 344."; exit 1; }

# Apply settings to the lamp
set_light_state "$power" "$brightness" "$temperature"

echo "Elgato light set to: Power=$power, Brightness=$brightness, Temperature=$temperature"

