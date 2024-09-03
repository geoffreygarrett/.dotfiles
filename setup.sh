#!/bin/bash

set -euo pipefail

# ANSI Color Codes for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# Global Variables
GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="${REPO_NAME:-celestial-blueprint}"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Utility Functions for logging
log() {
    local level=$1
    local message=$2
    echo -e "${BOLD}[`date '+%Y-%m-%d %H:%M:%S'`] ${!level}: $message${RESET}"
}

# Check if Nix is installed and install it if it isn't
ensure_nix() {
    if ! command -v nix &>/dev/null; then
        log "YELLOW" "Nix is not installed. Installing..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
    else
        log "GREEN" "Nix is already installed."
    fi
}

# Clone the repository or update if it already exists
clone_or_update_repo() {
    if [ ! -d "$REPO_NAME" ]; then
        log "BLUE" "Cloning repository: $REPO_URL"
        git clone "$REPO_URL"
    else
        log "BLUE" "Updating repository: $REPO_NAME"
        (cd "$REPO_NAME" && git pull --rebase)
    fi
}

# Run the Nix flake
run_flake() {
    local flake_path="${PWD}/${REPO_NAME}"
    log "BLUE" "Running Nix flake in: $flake_path"
    nix run "$flake_path#homeConfigurations.$(whoami)@$(hostname | cut -d '.' -f 1 | tr '[:upper:]' '[:lower:]').activationPackage"
}

main() {
    log "GREEN" "Starting setup process..."
    ensure_nix
    clone_or_update_repo
    run_flake
    log "GREEN" "Setup completed successfully!"
}

main "$@"
