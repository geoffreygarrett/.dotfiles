#!/bin/bash

# File to store the JSON output
JSON_FILE="tailscale_hosts.json"

# Get Tailscale status and filter out the header
TAILSCALE_STATUS=$(tailscale status | tail -n +2)

# Create a temporary file for jq processing
TEMP_FILE=$(mktemp)

# Start the JSON object
echo "{" > "$TEMP_FILE"

# Process each line of the Tailscale status
while IFS= read -r line; do
    # Extract IP, hostname, and user from each line
    IP=$(echo "$line" | awk '{print $1}')
    HOSTNAME=$(echo "$line" | awk '{print $2}')
    USER=$(echo "$line" | awk '{print $3}' | cut -d@ -f1)

    # Add the entry to the JSON file
    echo "  \"$IP\": {" >> "$TEMP_FILE"
    echo "    \"hostname\": \"$HOSTNAME\"," >> "$TEMP_FILE"
    echo "    \"user\": \"$USER\"" >> "$TEMP_FILE"
    echo "  }," >> "$TEMP_FILE"
done <<< "$TAILSCALE_STATUS"

# Remove the trailing comma from the last entry
sed -i '$ s/,$//' "$TEMP_FILE"

# Close the JSON object
echo "}" >> "$TEMP_FILE"

# Use jq to format the JSON nicely and save it to the final file
jq '.' "$TEMP_FILE" > "$JSON_FILE"

# Clean up the temporary file
rm "$TEMP_FILE"

echo "Tailscale hostnames have been updated in $JSON_FILE"