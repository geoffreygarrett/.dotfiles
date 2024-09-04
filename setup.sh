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
LOG_LEVEL="INFO"
LOCAL_DEV=false

# Define keybinding constants as arrays
KEYBINDINGS_LINUX=(
    "<Super>Return:Alacritty:$HOME/.local/bin/alacritty-gl"
    "<Super>F:Alacritty Fullscreen:wmctrl -r :ACTIVE: -b toggle,fullscreen"
)
KEYBINDINGS_MACOS=(
    "cmd+alt+t:Alacritty:open -a Alacritty"
    "cmd+alt+f:Alacritty Fullscreen:Alacritty:toggleFullScreen"
)

# Enhanced logging function
log() {
    local level="$1"
    local message="$2"
    # shellcheck disable=SC2034
    local verbose_only="${3:-false}"

    local level_priority
    case "$level" in
        ERROR)   level_priority=0 ;;
        WARNING) level_priority=1 ;;
        SUCCESS) level_priority=2 ;;
        INFO)    level_priority=3 ;;
        DEBUG)   level_priority=4 ;;
        *)       level_priority=5 ;;
    esac

    local log_level_priority
    case "$LOG_LEVEL" in
        ERROR)   log_level_priority=0 ;;
        WARNING) log_level_priority=1 ;;
        SUCCESS) log_level_priority=2 ;;
        INFO)    log_level_priority=3 ;;
        DEBUG)   log_level_priority=4 ;;
        *)       log_level_priority=5 ;;
    esac

    if [[ $level_priority -le $log_level_priority ]]; then
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
    fi
}

# Verbose logging wrapper
vlog() {
    log "DEBUG" "$1"
}

# Get the appropriate dotfiles directory based on OS
get_dotfiles_dir() {
    if [ "$LOCAL_DEV" = true ]; then
        echo "$PWD"
    else
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
    fi
}

# Process hostname
process_hostname() {
    hostname -s 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "default"
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
    if [ "$LOCAL_DEV" = true ]; then
        log "INFO" "Running in local development mode. Skipping repository clone/update."
        return
    fi

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
    if ! nix run --impure "${dotfiles_dir}#homeConfigurations.$(whoami)@$(process_hostname).activationPackage" 2>&1 | while IFS= read -r line; do
        vlog "$line"
    done; then
        log "ERROR" "Failed to run Nix flake"
        exit 1
    fi
}

# Setup keyboard shortcuts for Linux
setup_linux_shortcuts() {
    log "INFO" "Setting up keyboard shortcuts for Linux..."

    # Initialize an array to store new bindings
    new_bindings=()

    for i in "${!KEYBINDINGS_LINUX[@]}"; do
        IFS=':' read -r key app command <<< "${KEYBINDINGS_LINUX[$i]}"

        # Create a new custom binding path
        new_binding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/"

        # Add the new binding path to our array
        new_bindings+=("'$new_binding_path'")

        # Set up the new keybinding
        log "DEBUG" "Setting up keybinding: $app ($key) -> $command"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" name "$app"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" command "$command"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" binding "$key"

        # Verify the settings
        log "DEBUG" "Verifying keybinding settings for $app:"
        log "DEBUG" "  Name: $(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" name)"
        log "DEBUG" "  Command: $(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" command)"
        log "DEBUG" "  Binding: $(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$new_binding_path" binding)"
    done

    # Join the array elements with commas
    all_bindings=$(IFS=,; echo "${new_bindings[*]}")

    # Update the list of custom keybindings
    log "DEBUG" "Setting custom-keybindings to: [$all_bindings]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$all_bindings]"

    # Verify the final custom-keybindings setting
    log "DEBUG" "Verifying final custom-keybindings setting:"
    log "DEBUG" "$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"

    log "SUCCESS" "Linux keyboard shortcuts set up successfully."
}

# Setup keyboard shortcuts for macOS
setup_macos_shortcuts() {
    log "INFO" "Setting up keyboard shortcuts for macOS..."
    if ! command -v brew &>/dev/null; then
        log "WARNING" "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! command -v hammerspoon &>/dev/null; then
        log "INFO" "Installing Hammerspoon..."
        brew install --cask hammerspoon
    fi

    mkdir -p "$HOME/.hammerspoon"
    cat > "$HOME/.hammerspoon/init.lua" << EOL
local function bindKey(mod, key, fn)
    hs.hotkey.bind(mod, key, fn)
end

EOL

    for binding in "${KEYBINDINGS_MACOS[@]}"; do
        IFS=':' read -r key app command <<< "$binding"
        log "DEBUG" "Setting up keybinding: $app ($key) -> $command"
        echo "bindKey('$key', function() hs.application.launchOrFocus('$app') end)" >> "$HOME/.hammerspoon/init.lua"
    done

    echo "hs.alert.show('Hammerspoon config loaded')" >> "$HOME/.hammerspoon/init.lua"

    log "SUCCESS" "macOS keyboard shortcuts set up successfully. Please restart Hammerspoon to apply changes."
}

# Setup keyboard shortcuts based on the OS
setup_shortcuts() {
    case "$(uname)" in
        Linux)
            setup_linux_shortcuts
            ;;
        Darwin)
#            setup_macos_shortcuts
            ;;
        MINGW*|MSYS*|CYGWIN*)
            log "WARNING" "Keyboard shortcut setup for Windows is managed in the PowerShell script."
            ;;
        *)
            log "ERROR" "Unsupported operating system for keyboard shortcut setup."
            ;;
    esac
}

main() {
    # Parse command line arguments
    while getopts ":vl:d" opt; do
        case ${opt} in
            v )
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                ;;
            l )
                LOG_LEVEL="$OPTARG"
                ;;
            d )
                LOCAL_DEV=true
                ;;
            \? )
                log "ERROR" "Invalid Option: -$OPTARG" 1>&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    log "INFO" "Starting setup process..."
    if [ "$LOCAL_DEV" = true ]; then
        log "INFO" "Running in local development mode"
    fi
    ensure_nix
    clone_or_update_repo
    run_flake
    setup_shortcuts
    log "SUCCESS" "Setup completed successfully!"
}

main "$@"