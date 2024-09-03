#!/usr/bin/env bash
set -euo pipefail

# ANSI Color Codes for logging
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Global Variables
readonly GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
readonly REPO_NAME="${REPO_NAME:-celestial-blueprint}"
readonly REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
VERBOSE=false

# Enhanced logging function
log() {
    local level="$1"
    local message="$2"
    local verbose_only="${3:-false}"

    if [[ "$verbose_only" == "true" && "$VERBOSE" == "false" ]]; then
        return
    fi

    local color
    case "$level" in
        INFO)    color="$BLUE" ;;
        SUCCESS) color="$GREEN" ;;
        WARNING) color="$YELLOW" ;;
        ERROR)   color="$RED" ;;
        DEBUG)   color="$GRAY" ;;
        *)       color="$RESET" ;;
    esac

    echo -e "${BOLD}[$(date '+%Y-%m-%d %H:%M:%S')] ${color}${level}${RESET}: ${message}" >&2
}

# Verbose logging wrapper
vlog() {
    log "DEBUG" "$1" true
}

# Get the appropriate dotfiles directory based on OS
get_dotfiles_dir() {
    case "$(uname)" in
        Darwin|Linux)
            echo "$HOME/.dotfiles"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "${USERPROFILE:?}/.dotfiles"
            ;;
        *)
            log "ERROR" "Unsupported operating system"
            exit 1
            ;;
    esac
}

# Process hostname
process_hostname() {
    hostname -s 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "unknown-host"
}

# Check if Nix is installed and install it if it isn't
ensure_nix() {
    if ! command -v nix &>/dev/null; then
        log "WARNING" "Nix is not installed. Installing..."
        if ! curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes; then
            log "ERROR" "Failed to install Nix"
            exit 1
        fi
        # Source nix
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    else
        log "SUCCESS" "Nix is already installed."
    fi
}

# Clone the repository or update if it already exists
clone_or_update_repo() {
    local dotfiles_dir
    dotfiles_dir=$(get_dotfiles_dir)
    if [ ! -d "$dotfiles_dir" ]; then
        log "INFO" "Cloning repository: $REPO_URL into $dotfiles_dir"
        if ! git clone "$REPO_URL" "$dotfiles_dir"; then
            log "ERROR" "Failed to clone repository"
            exit 1
        fi
    else
        log "INFO" "Updating repository in $dotfiles_dir"
        if ! (cd "$dotfiles_dir" && git pull --rebase 2>&1 | while IFS= read -r line; do
            vlog "$line"
        done); then
            log "ERROR" "Failed to update repository"
            exit 1
        fi
    fi
}

# Run the Nix flake
run_flake() {
    local dotfiles_dir
    dotfiles_dir=$(get_dotfiles_dir)
    log "INFO" "Running Nix flake in: $dotfiles_dir"
    if ! nix run "${dotfiles_dir}#homeConfigurations.$(whoami)@$(process_hostname).activationPackage" 2>&1 | while IFS= read -r line; do
        vlog "$line"
    done; then
        log "ERROR" "Failed to run Nix flake"
        exit 1
    fi
}

main() {
    # Parse command line arguments
    while getopts ":v" opt; do
        case ${opt} in
            v )
                VERBOSE=true
                ;;
            \? )
                log "ERROR" "Invalid Option: -$OPTARG" 1>&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    log "INFO" "Starting setup process..."
    ensure_nix
    clone_or_update_repo
    run_flake
    log "SUCCESS" "Setup completed successfully!"
}

main "$@"