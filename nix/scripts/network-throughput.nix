{
  pkgs ? import <nixpkgs> { },
}:

let
  network-throughput-test = pkgs.writeShellScriptBin "network-throughput-test" ''
    set -euo pipefail

    # Default values
    ssh_target="geoffrey@192.168.68.114"
    block_size="1GB"
    count=3

    # Function to print usage information
    print_usage() {
      echo "Usage: network-throughput-test [OPTIONS]"
      echo "Options:"
      echo "  -t, --target TARGET    SSH target (default: $ssh_target)"
      echo "  -b, --block-size SIZE  Block size for dd (default: $block_size)"
      echo "  -c, --count COUNT      Number of blocks to transfer (default: $count)"
      echo "  -h, --help             Print this help message"
    }

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
      case $1 in
        -t|--target)
          ssh_target="$2"
          shift 2
          ;;
        -b|--block-size)
          block_size="$2"
          shift 2
          ;;
        -c|--count)
          count="$2"
          shift 2
          ;;
        -h|--help)
          print_usage
          exit 0
          ;;
        *)
          echo "Error: Unknown option $1" >&2
          print_usage
          exit 1
          ;;
      esac
    done

    echo "Testing network throughput from $ssh_target"
    echo "Transferring $count blocks of $block_size each"

    # Run the network throughput test
    if ! ssh "$ssh_target" "dd if=/dev/zero bs=$block_size count=$count 2>/dev/null" | dd of=/dev/null status=progress; then
      echo "Error: Network throughput test failed" >&2
      exit 1
    fi

    echo "Test complete. The results show the rate at which data was transferred and processed."
  '';
in
{
  inherit network-throughput-test;
}
