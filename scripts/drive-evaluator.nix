{
  pkgs ? import <nixpkgs> { },
}:

let
  script = pkgs.writeShellScriptBin "drive-evaluator" ''
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
      printf "''${color}%s''${NC}\n" "$message"
    }

    # Function for debug output
    debug() {
      echo "DEBUG: $1" >&2
    }

    # Check for root privileges
    if [ "$(id -u)" -ne 0 ]; then
      print_color "$RED" "This script must be run as root"
      exit 1
    fi

    print_color "$BLUE" "Checking for required tools..."

    # Function to get drive information
    get_drive_info() {
      local drive="$1"
      local info

      print_color "$YELLOW" "Fetching drive information..."
      debug "Running: ${pkgs.smartmontools}/bin/smartctl -i -j $drive"
      info=$(${pkgs.smartmontools}/bin/smartctl -i -j "$drive" 2>&1)
      debug "smartctl output: $info"

      if [ $? -ne 0 ]; then
        print_color "$RED" "Error running smartctl. Exit code: $?"
        return 1
      fi

      if echo "$info" | ${pkgs.jq}/bin/jq -e '.smartctl.messages[].severity == "error"' > /dev/null; then
        print_color "$YELLOW" "smartctl failed to recognize the device. Falling back to lsblk..."
        local lsblk_info=$(${pkgs.util-linux}/bin/lsblk -ndo MODEL,SIZE,SERIAL "$drive")
        debug "lsblk output: $lsblk_info"

        if [ -z "$lsblk_info" ]; then
          print_color "$RED" "Error: lsblk failed to retrieve information"
          return 1
        fi

        local model=$(echo "$lsblk_info" | awk '{print $1}')
        local capacity=$(echo "$lsblk_info" | awk '{print $2}')
        local serial=$(echo "$lsblk_info" | awk '{print $3}')

        # If serial is empty, it might be because the MODEL contained spaces
        if [ -z "$serial" ]; then
          model=$(echo "$lsblk_info" | awk '{$NF=""; $(NF-1)=""; print $0}' | sed 's/  *$//')
          capacity=$(echo "$lsblk_info" | awk '{print $(NF-1)}')
          serial=$(echo "$lsblk_info" | awk '{print $NF}')
        fi

        echo "Model: $model"
        echo "Serial: $serial"
        echo "Capacity: $capacity"
        echo "Note: Detailed SMART information is not available for this device."
      else
        local model=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.model_name // "Unknown"')
        local serial=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.serial_number // "Unknown"')
        local capacity=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.user_capacity.bytes // 0')
        local sector_size=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.logical_block_size // 0')

        echo "Model: $model"
        echo "Serial: $serial"
        echo "Capacity: $(${pkgs.coreutils}/bin/numfmt --to=iec-i --suffix=B $capacity)"
        echo "Sector Size: $sector_size bytes"
      fi
    }

    # Function to get SMART attributes (modify to handle non-SMART devices)
    get_smart_attributes() {
      local drive="$1"
      local smart_data

      print_color "$YELLOW" "Fetching SMART attributes..."
      smart_data=$(${pkgs.smartmontools}/bin/smartctl -A -j "$drive" 2>&1)

      if echo "$smart_data" | ${pkgs.jq}/bin/jq -e '.smartctl.messages[].severity == "error"' > /dev/null; then
        echo "SMART attributes are not available for this device."
      else
        echo "SMART Attributes:"
        echo "$smart_data" | ${pkgs.jq}/bin/jq -r '.ata_smart_attributes.table[] |
        "  \(.name): \(.raw.value) (\(.thresh) threshold)"' 2>/dev/null
      fi
    }

    # Function to perform read/write speed test
    perform_speed_test() {
      local drive="$1"
      local test_file="/tmp/speed_test_file"
      local test_size="1G"
      local mount_point=""

      print_color "$YELLOW" "Performing speed tests (this may take a few minutes)..."

      # Check if the drive is mounted
      mount_point=$(${pkgs.util-linux}/bin/lsblk -no MOUNTPOINT "$drive")
      if [ -n "$mount_point" ]; then
        test_file="$mount_point/speed_test_file"
      else
        print_color "$YELLOW" "Drive is not mounted. Using /tmp for speed test."
      fi

      # Write speed test
      echo "Write speed test..."
      ${pkgs.coreutils}/bin/dd if=/dev/zero of="$test_file" bs=1M count=1024 conv=fdatasync 2>&1 | ${pkgs.gawk}/bin/awk '/copied/ {print $NF}'

      # Read speed test
      echo "Read speed test..."
      ${pkgs.coreutils}/bin/dd if="$test_file" of=/dev/null bs=1M count=1024 2>&1 | ${pkgs.gawk}/bin/awk '/copied/ {print $NF}'

      ${pkgs.coreutils}/bin/rm -f "$test_file"
    }

    # Function to perform detailed IO test using fio
    perform_io_test() {
      local drive="$1"
      local test_file="/tmp/fio_test_file"
      local mount_point=""

      print_color "$YELLOW" "Performing detailed IO tests (this may take several minutes)..."

      # Check if the drive is mounted
      mount_point=$(${pkgs.util-linux}/bin/lsblk -no MOUNTPOINT "$drive")
      if [ -n "$mount_point" ]; then
        test_file="$mount_point/fio_test_file"
      else
        print_color "$YELLOW" "Drive is not mounted. Using /tmp for IO test."
      fi

      ${pkgs.fio}/bin/fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=1g \
      --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1 \
      --filename="$test_file" --output-format=json --output="/tmp/fio_results.json"

      local write_iops=$(${pkgs.jq}/bin/jq '.jobs[0].write.iops' /tmp/fio_results.json)
      local write_bw=$(${pkgs.jq}/bin/jq '.jobs[0].write.bw' /tmp/fio_results.json)

      echo "Random Write IOPS: $write_iops"
      echo "Random Write Bandwidth: $write_bw KB/s"

      ${pkgs.coreutils}/bin/rm -f "$test_file" "/tmp/fio_results.json"
    }

    # Main script
    print_color "$BLUE" "USB/HDD Evaluation Script"
    echo "--------------------------------"

    # List available drives
    print_color "$GREEN" "Available drives:"
    ${pkgs.util-linux}/bin/lsblk -d -o NAME,SIZE,MODEL,TRAN | ${pkgs.gnugrep}/bin/grep -E 'usb|sata|nvme'

    # Prompt user to select a drive
    printf "Enter the drive to evaluate (e.g., sda, nvme0n1): "
    read drive
    drive="/dev/''${drive}"

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
    read_speed=$(perform_speed_test "$drive" | ${pkgs.coreutils}/bin/tail -n 1)
    write_speed=$(perform_speed_test "$drive" | ${pkgs.coreutils}/bin/head -n 1)
    echo "Read Speed: $read_speed"
    echo "Write Speed: $write_speed"

    echo
    print_color "$GREEN" "IO Test Results:"
    perform_io_test "$drive"

    # Generate JSON output
    output_file="drive_evaluation_$(${pkgs.coreutils}/bin/date +%Y%m%d_%H%M%S).json"
    print_color "$YELLOW" "Generating JSON output..."
    ${pkgs.jq}/bin/jq -n \
      --arg drive "$drive" \
      --arg model "$(get_drive_info "$drive" | ${pkgs.gnugrep}/bin/grep 'Model:' | ${pkgs.coreutils}/bin/cut -d' ' -f2-)" \
      --arg serial "$(get_drive_info "$drive" | ${pkgs.gnugrep}/bin/grep 'Serial:' | ${pkgs.coreutils}/bin/cut -d' ' -f2-)" \
      --arg capacity "$(get_drive_info "$drive" | ${pkgs.gnugrep}/bin/grep 'Capacity:' | ${pkgs.coreutils}/bin/cut -d' ' -f2-)" \
      --arg sector_size "$(get_drive_info "$drive" | ${pkgs.gnugrep}/bin/grep 'Sector Size:' | ${pkgs.coreutils}/bin/cut -d' ' -f3-)" \
      --arg read_speed "$read_speed" \
      --arg write_speed "$write_speed" \
      --argjson smart "$(${pkgs.smartmontools}/bin/smartctl -A -j "$drive")" \
      --argjson io_test "$(${pkgs.coreutils}/bin/cat /tmp/fio_results.json)" \
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
  '';

  wrapperScript = pkgs.writeShellScriptBin "run-drive-evaluator" ''
    #!${pkgs.bash}/bin/bash
    if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root. Trying with sudo..."
      exec sudo -E PATH="$PATH" $0 "$@"
    else
      exec ${script}/bin/drive-evaluator "$@"
    fi
  '';
in
pkgs.stdenv.mkDerivation {
  name = "drive-evaluator";
  buildInputs = [
    pkgs.bash
    pkgs.coreutils
    pkgs.smartmontools
    pkgs.util-linux
    pkgs.fio
    pkgs.jq
    pkgs.gawk
    pkgs.gnugrep
  ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${script}/bin/drive-evaluator $out/bin/
    cp ${wrapperScript}/bin/run-drive-evaluator $out/bin/
  '';
}
