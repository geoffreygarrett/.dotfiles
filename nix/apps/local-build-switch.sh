#!/usr/bin/env bash

set -euo pipefail

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to echo with color
echo_color() {
  echo -e "${2}${1}${NC}"
}

# Detect system type and architecture
OS=$(uname)
ARCH=$(uname -m)

case "$OS" in
  Darwin)
    case "$ARCH" in
      x86_64) SYSTEM_TYPE="x86_64-darwin" ;;
      arm64) SYSTEM_TYPE="aarch64-darwin" ;;
      *)
        echo_color "Unsupported Darwin architecture: $ARCH" "$RED"
        exit 1
        ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64) SYSTEM_TYPE="x86_64-linux" ;;
      aarch64) SYSTEM_TYPE="aarch64-linux" ;;
      *)
        echo_color "Unsupported Linux architecture: $ARCH" "$RED"
        exit 1
        ;;
    esac
    ;;
  *)
    echo_color "Unsupported operating system: $OS" "$RED"
    exit 1
    ;;
esac

# Function to check if Nix is installed
check_nix() {
  if ! command -v nix &>/dev/null; then
    echo_color "Nix is not installed. Please install Nix first." "$RED"
    exit 1
  fi
}

# Function to build the Home Manager configuration
build_config() {
  echo_color "Building Home Manager configuration for $SYSTEM_TYPE..." "$YELLOW"
  nix build ".#homeConfigurations.$SYSTEM_TYPE.activationPackage" --extra-experimental-features "nix-command flakes" "$@"
}

# Function to activate the new Home Manager configuration
activate_config() {
  echo_color "Activating new Home Manager configuration..." "$YELLOW"
  ./result/activate
}

# Main execution
main() {
  check_nix

  echo_color "Starting local Nix configuration for $SYSTEM_TYPE..." "$YELLOW"

  build_config "$@"
  activate_config

  echo_color "Cleaning up..." "$YELLOW"
  unlink ./result

  echo_color "Local Nix configuration update complete!" "$GREEN"
}

# Run the main function
main "$@"
