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
        FLAKE_ATTR="darwinConfigurations.$SYSTEM_TYPE.system"
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
        FLAKE_ATTR="nixosConfigurations.$SYSTEM_TYPE.config.system.build.toplevel"
        ;;
    *)
        echo_color "Unsupported operating system: $OS" "$RED"
        exit 1
        ;;
esac

# Function to check if running with sudo
check_sudo() {
    if [ "$OS" = "Linux" ] && [ "$EUID" -ne 0 ]; then
        echo_color "This script must be run with sudo on Linux." "$RED"
        exit 1
    fi
}

# Function to build the configuration
build_config() {
    echo_color "Building configuration for $SYSTEM_TYPE..." "$YELLOW"
    nix build ".#$FLAKE_ATTR" --extra-experimental-features "nix-command flakes" "$@"
}

# Function to switch to the new configuration
switch_config() {
    echo_color "Switching to new configuration..." "$YELLOW"
    if [ "$OS" = "Darwin" ]; then
        ./result/sw/bin/darwin-rebuild switch --flake ".#$SYSTEM_TYPE"
    elif [ "$OS" = "Linux" ]; then
        ./result/bin/switch-to-configuration switch
    fi
}

# Main execution
main() {
    check_sudo

    echo_color "Starting global Nix configuration for $SYSTEM_TYPE..." "$YELLOW"

    build_config "$@"
    switch_config

    echo_color "Cleaning up..." "$YELLOW"
    unlink ./result

    echo_color "Global Nix configuration update complete!" "$GREEN"
}

# Run the main function
main "$@"
