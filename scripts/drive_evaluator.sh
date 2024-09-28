#!/usr/bin/env bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
  local color="$1"
  local message="$2"
  printf "${color}%s${NC}\n" "$message"
}

# Function to check if a command exists
command_exists() {
  if command -v "$1" >/dev/null 2>&1
  then
    return 0
  elif type "$1" >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Debug function
debug_info() {
  echo "Debug: PATH = $PATH"
  echo "Debug: Current user = $(whoami)"
  echo "Debug: fio location = $(which fio 2>/dev/null || echo 'not found')"
  echo "Debug: command_exists fio result = $?"
}

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
  print_color "$RED" "This script must be run as root"
  exit 1
fi

print_color "$BLUE" "Checking for required tools..."

# Check for required tools
required_tools="smartctl hdparm fio jq"
missing_tools=""
for tool in $required_tools; do
  if ! command_exists "$tool"; then
    missing_tools="$missing_tools $tool"
  fi
done

if [ -n "$missing_tools" ]; then
  print_color "$RED" "Error: The following tools are not installed or not in PATH:$missing_tools"
  print_color "$RED" "Please install them and try again."
  debug_info
  exit 1
fi

print_color "$GREEN" "All required tools are available."

# Function to get drive information
get_drive_info() {
  local drive="$1"
  local info

  print_color "$YELLOW" "Fetching drive information..."
  info=$(smartctl -i -j "$drive")

  local model=$(echo "$info" | jq -r '.model_name // "Unknown"')
  local serial=$(echo "$info" | jq -r '.serial_number // "Unknown"')
  local capacity=$(echo "$info" | jq -r '.user_capacity.bytes // 0')
  local sector_size=$(echo "$info" | jq -r '.logical_block_size // 0')

  echo "Model: $model"
  echo "Serial: $serial"
  echo "Capacity: $(numfmt --to=iec-i --suffix=B $capacity)"
  echo "Sector Size: $sector_size bytes"
}

# Function to get SMART attributes
get_smart_attributes() {
  local drive="$1"
  local smart_data

  print_color "$YELLOW" "Fetching SMART attributes..."
  smart_data=$(smartctl -A -j "$drive")

  echo "SMART Attributes:"
  echo "$smart_data" | jq -r '.ata_smart_attributes.table[] |
  "  \(.name): \(.raw.value) (\(.thresh) threshold)"' 2>/dev/null
}

# Function to perform read/write speed test
perform_speed_test() {
  local drive="$1"
  local test_file="/tmp/speed_test_file"

  print_color "$YELLOW" "Performing speed tests (this may take a few minutes)..."

  # Write speed test
  echo "Write speed test..."
  dd if=/dev/zero of="$test_file" bs=1G count=1 oflag=direct 2>&1 | grep -oP 'copied,.*?(\d+(\.\d+)?\s+\w+/s)' | awk '{print $NF}'
  sync

  # Read speed test
  echo "Read speed test..."
  dd if="$test_file" of=/dev/null bs=1G count=1 iflag=direct 2>&1 | grep -oP 'copied,.*?(\d+(\.\d+)?\s+\w+/s)' | awk '{print $NF}'

  rm "$test_file"
}

# Function to perform detailed IO test using fio
perform_io_test() {
  local drive="$1"
  local test_file="/tmp/fio_test_file"

  print_color "$YELLOW" "Performing detailed IO tests (this may take several minutes)..."

  fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=1g \
    --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1 \
    --filename="$test_file" --output-format=json --output="/tmp/fio_results.json"

  local write_iops=$(jq '.jobs[0].write.iops' /tmp/fio_results.json)
  local write_bw=$(jq '.jobs[0].write.bw' /tmp/fio_results.json)

  echo "Random Write IOPS: $write_iops"
  echo "Random Write Bandwidth: $write_bw KB/s"

  rm "$test_file" "/tmp/fio_results.json"
}

# Main script
print_color "$BLUE" "USB/HDD Evaluation Script"
echo "--------------------------------"

# List available drives
print_color "$GREEN" "Available drives:"
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E 'usb|sata|nvme'

# Prompt user to select a drive
printf "Enter the drive to evaluate (e.g., sda, nvme0n1): "
read drive
drive="/dev/${drive}"

if [ ! -b "$drive" ]; then
  print_color "$RED" "Error: $drive is not a valid block device."
  exit 1
fi

# Collect and display information
echo
print_color "$GREEN" "Drive Information:"
get_drive_info "$drive"

echo
print_color "$GREEN" "SMART Information:"
get_smart_attributes "$drive"

echo
print_color "$GREEN" "Speed Test Results:"
read_speed=$(perform_speed_test "$drive" | tail -n 1)
write_speed=$(perform_speed_test "$drive" | head -n 1)
echo "Read Speed: $read_speed"
echo "Write Speed: $write_speed"

echo
print_color "$GREEN" "IO Test Results:"
perform_io_test "$drive"

# Generate JSON output
output_file="drive_evaluation_$(date +%Y%m%d_%H%M%S).json"
print_color "$YELLOW" "Generating JSON output..."
jq -n \
  --arg drive "$drive" \
  --arg model "$(get_drive_info "$drive" | grep 'Model:' | cut -d' ' -f2-)" \
  --arg serial "$(get_drive_info "$drive" | grep 'Serial:' | cut -d' ' -f2-)" \
  --arg capacity "$(get_drive_info "$drive" | grep 'Capacity:' | cut -d' ' -f2-)" \
  --arg sector_size "$(get_drive_info "$drive" | grep 'Sector Size:' | cut -d' ' -f3-)" \
  --arg read_speed "$read_speed" \
  --arg write_speed "$write_speed" \
  --argjson smart "$(smartctl -A -j "$drive")" \
  --argjson io_test "$(cat /tmp/fio_results.json)" \
  '{
    drive: $drive,
    model: $model,
    serial: $serial,
    capacity: $capacity,
    sector_size: $sector_size,
    read_speed: $read_speed,
    write_speed: $write_speed,
    smart: $smart,
    io_test: $io_test
}' > "$output_file"

print_color "$GREEN" "Evaluation complete. Results saved to $output_file"