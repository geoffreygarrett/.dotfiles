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
REPO_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
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

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_with_spinner() {
    local command="$1"
    local log_file=$(mktemp)

    if [[ "$command" == *"sudo"* ]]; then
        eval "$command"
    else
        eval "$command" > "$log_file" 2>&1 &
        local pid=$!
        spinner $pid

        wait $pid
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            log "ERROR" "Command failed: $command"
            cat "$log_file"
        fi

        rm "$log_file"
        return $exit_code
    fi
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

usage() {
    log "INFO" "Usage: bash <(curl -sL https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/main/setup.sh) [--local]"
    log "INFO" "You can override the default GitHub username and repository name by setting the GITHUB_USERNAME and REPO_NAME environment variables."
    log "INFO" "Use the --local flag to use the local repository instead of cloning from GitHub."
}

install_dependencies() {
    local os=$(detect_os)

    case "$os" in
        "linux")
            run_with_spinner "sudo apt-get update && sudo apt-get install -y software-properties-common"
            run_with_spinner "sudo add-apt-repository --yes --update ppa:ansible/ansible"
            run_with_spinner "sudo apt-get install -y ansible git curl"
            ;;
        "macos")
            if ! command -v brew &> /dev/null; then
                log "INFO" "Homebrew not found. Installing Homebrew..."
                run_with_spinner "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            fi
            run_with_spinner "brew install ansible git curl"
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
            run_with_spinner "git clone \"$REPO_URL\""
        else
            (cd "$REPO_NAME" && run_with_spinner "git pull --rebase")
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
    fi
}

cleanup() {
    if [ "$USE_LOCAL_REPO" = false ]; then
        log "INFO" "Cleaning up..."
        cd ..
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