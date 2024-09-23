#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Define the hosts configuration in JSON format
hosts_json='{
  "100.116.122.19": ["artemis.halfmoon-crocodile.ts.net"],
  "100.64.241.11": ["crazy-diamond.halfmoon-crocodile.ts.net"],
  "100.92.233.30": ["crazy-phone.halfmoon-crocodile.ts.net"],
  "100.111.132.9": ["dodo-iphone.halfmoon-crocodile.ts.net"],
  "100.91.33.40": ["google-chromecast.halfmoon-crocodile.ts.net"],
  "100.98.196.120": ["nimbus.halfmoon-crocodile.ts.net"],
  "100.78.156.17": ["pioneer.halfmoon-crocodile.ts.net"],
  "100.112.193.127": ["voyager.halfmoon-crocodile.ts.net"]
}'

# Extract and calculate the maximum widths of columns
max_ip_width=$(echo "$hosts_json" | jq -r 'keys[] | length' | sort -nr | head -n1)
max_hostname_width=$(echo "$hosts_json" | jq -r 'to_entries[].value[] | length' | sort -nr | head -n1)

# Print table header with colors
printf "${CYAN}| %-${max_ip_width}s | %-${max_hostname_width}s |\n" "IP Address" "Hostnames"
printf "${CYAN}|-%-${max_ip_width}s-|-%-${max_hostname_width}s-|\n" "$(printf '%*s' "${max_ip_width}" | tr ' ' '-')" "$(printf '%*s' "${max_hostname_width}" | tr ' ' '-')"
printf "${NC}"

# Loop through each entry in the JSON object
for ip in $(echo "$hosts_json" | jq -r 'keys[]'); do
  # Get the list of hostnames for the current IP address
  hostnames=$(echo "$hosts_json" | jq -r ".[\"$ip\"] | @tsv")

  # Print the IP address and hostnames in a table format with colors
  printf "${GREEN}| %-${max_ip_width}s | %-${max_hostname_width}s |\n" "$ip" "$hostnames"
done
