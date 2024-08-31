#!/bin/bash

set -euo pipefail

# ==========================================================================
# ANSI Color Codes
# ==========================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ==========================================================================
# Global Variables
# ==========================================================================

GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="${REPO_NAME:-cross-platform-terminal-setup}"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
SETUP_TAG="${SETUP_TAG:-setup}"
USE_LOCAL_REPO=false

# ==========================================================================
# Utility Functions
# ==========================================================================

log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO")    local color=$BLUE ;;
        "WARNING") local color=$YELLOW ;;
        "ERROR")   local color=$RED ;;
        "SUCCESS") local color=$GREEN ;;
        "DEBUG")   local color=$GRAY ;;
        *)         local color=$RESET ;;
    esac

    echo -e "${BOLD}[${timestamp}]${RESET} ${color}${level}${RESET}: ${message}"
}

error() {
    log "ERROR" "$1"
    exit 1
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

# ==========================================================================
# Main Functions
# ==========================================================================

install_dependencies() {
    local os=$(detect_os)

    case "$os" in
        "linux")
            log "INFO" "Running on Linux, installing dependencies..."

            # Disable interactive prompts
            export DEBIAN_FRONTEND=noninteractive

            # Update the package list and install required packages
            sudo apt-get update -y
            sudo apt-get install -y software-properties-common

            # Add the Ansible repository and update the package list again
            sudo add-apt-repository --yes --update ppa:ansible/ansible

            # Install Ansible, Git, and Curl
            sudo apt-get install -y ansible git curl

            # Reset DEBIAN_FRONTEND to its original state
            unset DEBIAN_FRONTEND
            ;;
        "macos")
            log "INFO" "Running on macOS, installing dependencies..."

            # Check if Homebrew is installed, and install it if necessary
            if ! command -v brew &> /dev/null; then
                log "INFO" "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            # Install Ansible, Git, and Curl using Homebrew
            brew install ansible git curl
            ;;
        *)
            error "Unsupported OS: $OSTYPE"
            ;;
    esac
}

clone_repository() {
    if [ "$USE_LOCAL_REPO" = true ]; then
        log "INFO" "Using local repository..."
    else
        if [[ ! -d "$REPO_NAME" ]]; then
            git clone "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
        else
            cd "$REPO_NAME"
            git pull --rebase
            cd ..
        fi
    fi
}

run_playbook() {
    log "INFO" "Running the Ansible playbook..."

    if [ "$USE_LOCAL_REPO" = true ]; then
        if [[ ! -f "playbook.yml" ]]; then
            error "Error: playbook.yml not found in the current directory."
        fi
        ansible-playbook -i "localhost," --connection=local playbook.yml --tags "$SETUP_TAG"
    else
        cd "$REPO_NAME"
        if [[ ! -f "playbook.yml" ]]; then
            error "Error: playbook.yml not found in the repository."
        fi
        ansible-playbook -i "localhost," --connection=local playbook.yml --tags "$SETUP_TAG"
        cd ..
    fi
}

cleanup() {
    if [ "$USE_LOCAL_REPO" = false ]; then
        log "INFO" "Cleaning up..."
        rm -rf "$REPO_NAME"
    fi
}

main() {
    log "INFO" "Starting setup process..."

    install_dependencies
    clone_repository
    run_playbook
    cleanup

    log "SUCCESS" "Setup completed successfully!"
}

# Parse the command-line arguments
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

if [[ "${1:-}" == "--local" ]]; then
    USE_LOCAL_REPO=true
fi

main "$@"
