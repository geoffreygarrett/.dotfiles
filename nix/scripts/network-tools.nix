{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.networkTools;

  wakePcScript = pkgs.writeShellScriptBin "wake-pc" ''
    PC_MAC=""
    PC_IP=""
    TIMEOUT=60
    INTERVAL=2

    usage() {
      echo "Usage: $0 -m MAC_ADDRESS -i IP_ADDRESS [-t TIMEOUT] [-n INTERVAL]"
      echo "  -m MAC_ADDRESS: MAC address of the target PC (required)"
      echo "  -i IP_ADDRESS: IP address of the target PC (required)"
      echo "  -t TIMEOUT: Maximum time to wait for PC to wake up in seconds (default: 60)"
      echo "  -n INTERVAL: Interval between ping attempts in seconds (default: 2)"
      exit 1
    }

    while getopts "m:i:t:n:" opt; do
      case $opt in
        m) PC_MAC=$OPTARG ;;
        i) PC_IP=$OPTARG ;;
        t) TIMEOUT=$OPTARG ;;
        n) INTERVAL=$OPTARG ;;
        *) usage ;;
      esac
    done

    if [ -z "$PC_MAC" ] || [ -z "$PC_IP" ]; then
      usage
    fi

    wake_pc() {
      ${pkgs.wakeonlan}/bin/wakeonlan $PC_MAC
      echo "Wake-on-LAN packet sent to $PC_MAC"
    }

    is_pc_awake() {
      ${pkgs.iputils}/bin/ping -c 1 $PC_IP > /dev/null 2>&1
      return $?
    }

    wake_pc

    echo "Waiting for PC to wake up..."
    end_time=$((SECONDS + TIMEOUT))
    while [ $SECONDS -lt $end_time ]; do
      if is_pc_awake; then
        echo "PC is awake!"
        exit 0
      fi
      sleep $INTERVAL
    done

    echo "PC did not wake up within the timeout period."
    exit 1
  '';

  discoverNetworkScript = pkgs.writeShellScriptBin "discover-network" ''
    SUBNET="192.168.1"
    START_IP=1
    END_IP=254
    TIMEOUT=1

    usage() {
      echo "Usage: $0 [-s SUBNET] [-b START_IP] [-e END_IP] [-t TIMEOUT]"
      echo "  -s SUBNET: Subnet to scan (default: 192.168.1)"
      echo "  -b START_IP: Start of IP range (default: 1)"
      echo "  -e END_IP: End of IP range (default: 254)"
      echo "  -t TIMEOUT: Ping timeout in seconds (default: 1)"
      exit 1
    }

    while getopts "s:b:e:t:" opt; do
      case $opt in
        s) SUBNET=$OPTARG ;;
        b) START_IP=$OPTARG ;;
        e) END_IP=$OPTARG ;;
        t) TIMEOUT=$OPTARG ;;
        *) usage ;;
      esac
    done

    echo "Scanning network for active devices..."
    echo "This may take a while depending on the IP range..."

    for ip in $(seq $START_IP $END_IP); do
      current_ip="$SUBNET.$ip"
      if ${pkgs.iputils}/bin/ping -c 1 -W $TIMEOUT $current_ip > /dev/null 2>&1; then
        echo "Device found at $current_ip"
        mac=$(${pkgs.nettools}/bin/arp -a $current_ip | awk '{print $4}')
        hostname=$(${pkgs.dnsutils}/bin/nslookup $current_ip | grep 'name =' | awk '{print $NF}' | sed 's/\.$//')
        echo "  MAC Address: $mac"
        echo "  Hostname: $hostname"
        echo ""
      fi
    done

    echo "Scan complete."
  '';

in
{
  options.services.networkTools = {
    enable = mkEnableOption "Enable network tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      wakePcScript
      discoverNetworkScript
    ];
  };
}
