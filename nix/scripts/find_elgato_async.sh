#!/usr/bin/env bash

# Default subnet if none is specified
DEFAULT_SUBNET="192.168.68"

# Elgato's default port for lights
ELGATO_PORT="9123"
FOUND_DEVICES=()

# Max number of concurrent jobs (to control resource usage)
MAX_JOBS=100

# Function to get the subnet dynamically if needed
get_subnet() {
    ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d'/' -f1 | sed 's/\.[0-9]*$//'
}

# Check if an Elgato light exists at the given IP
check_elgato() {
    local ip=$1
    response=$(curl --silent --max-time 1 --location --request GET "http://$ip:$ELGATO_PORT/elgato/lights" --header 'Content-Type: application/json')

    if [[ $response == *"numberOfLights"* ]]; then
        echo "Elgato device found at $ip"
        FOUND_DEVICES+=("$ip")
    fi
}

# Manage the number of concurrent jobs
wait_for_jobs() {
    while [[ $(jobs | wc -l) -ge $MAX_JOBS ]]; do
        sleep 0.1  # Wait for any job slot to free up
    done
}

# Scan the local subnet for Elgato devices
scan_network() {
    local subnet=$1
    for i in {1..254}; do
        ip="$subnet.$i"
        wait_for_jobs  # Limit concurrent jobs
        check_elgato $ip &  # Run in background
    done
    wait  # Wait for all background jobs to complete
}

# Get the subnet either from the user or dynamically
SUBNET=${1:-$DEFAULT_SUBNET}
if [[ "$SUBNET" == "auto" ]]; then
    SUBNET=$(get_subnet)
fi

if [[ -z "$SUBNET" ]]; then
    echo "Unable to detect the network subnet."
    exit 1
fi

# Run the network scan
echo "Scanning the network for Elgato devices on subnet $SUBNET..."
scan_network "$SUBNET"

# Ensure all jobs are finished before showing results
wait

# Show results
if [ ${#FOUND_DEVICES[@]} -eq 0 ]; then
    echo "No Elgato devices found on the network."
else
    echo "Elgato devices found on the following IPs:"
    for ip in "${FOUND_DEVICES[@]}"; do
        echo "- $ip"
    done
fi

