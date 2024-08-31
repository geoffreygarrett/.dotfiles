#!/bin/bash

set -e

# Source the log utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/utils.sh"

REPO_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
BACKUP_DIR="$HOME/.terminal_setup_backup_$(date +%Y%m%d%H%M%S)"
VERBOSE=false
# shellcheck disable=SC2034
MAX_VERBOSE_LINES=10

# Request sudo password upfront
sudo -v

# ==========================================================================
# Helper Functions
# ==========================================================================

get_dir_hash() {
    local dir="$1"
    find "$dir" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
}

paths_are_different() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$dest" ]; then
        return 0  # Paths are different if destination doesn't exist
    fi

    if [ -d "$src" ] && [ -d "$dest" ]; then
        # shellcheck disable=SC2155
        local src_hash=$(get_dir_hash "$src")
        # shellcheck disable=SC2155
        local dest_hash=$(get_dir_hash "$dest")
        [ "$src_hash" != "$dest_hash" ]
    else
        # shellcheck disable=SC2251
        ! cmp -s "$src" "$dest"
    fi
}

get_file_hash() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        sha256sum "$file" | awk '{print $1}'
    fi
}

files_are_different() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$dest" ]; then
        return 0  # Files are different if destination doesn't exist
    fi

    # shellcheck disable=SC2155
    local src_hash=$(get_file_hash "$src")
    # shellcheck disable=SC2155
    local dest_hash=$(get_file_hash "$dest")

    [ "$src_hash" != "$dest_hash" ]
}

update_config() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        # shellcheck disable=SC2155
        local target=$(readlink -f "$dest")
        if [ "$target" != "$src" ]; then
            ln -sf "$src" "$dest" || error "Failed to update symlink: $dest"
            log "INFO" "Updated symlink: $dest -> $src"
        else
            log "INFO" "Symlink already up to date: $dest"
        fi
    elif paths_are_different "$src" "$dest"; then
        if [ -d "$src" ]; then
            rsync -a --delete "$src/" "$dest/" || error "Failed to sync directory: $dest"
            log "INFO" "Updated directory: $dest"
        else
            cp -f "$src" "$dest" || error "Failed to copy file to: $dest"
            log "INFO" "Updated file: $dest"
        fi
    else
        log "INFO" "Config already up to date: $dest"
    fi
}

backup_configs() {
    log "INFO" "Backing up current configurations..."
    mkdir -p "$BACKUP_DIR"
    # shellcheck disable=SC2015
    [ -d ~/.config/alacritty ] && cp -r ~/.config/alacritty "$BACKUP_DIR/" || true
    # shellcheck disable=SC2015
    [ -d ~/.config/zellij ] && cp -r ~/.config/zellij "$BACKUP_DIR/" || true
    # shellcheck disable=SC2015
    [ -d ~/.config/nvim ] && cp -r ~/.config/nvim "$BACKUP_DIR/" || true
}

update_repo() {
    log "INFO" "Updating repository..."
    cd "$REPO_DIR" || error "Failed to change to repository directory"
    run_with_spinner "git pull" || error "Failed to pull latest changes"
}

# ==========================================================================
# Update Functions
# ==========================================================================

update_configs() {
    log "INFO" "Updating configurations..."
    mkdir -p ~/.config
    [ -d "$REPO_DIR/config/alacritty" ] && update_config "$REPO_DIR/config/alacritty" ~/.config/alacritty
    [ -d "$REPO_DIR/config/zellij" ] && update_config "$REPO_DIR/config/zellij" ~/.config/zellij
    [ -d "$REPO_DIR/config/nvim" ] && update_config "$REPO_DIR/config/nvim" ~/.config/nvim
}

update_packages() {
    log "INFO" "Updating packages..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        run_with_spinner "sudo -n apt-get update" || error "Failed to update package lists"
        run_with_spinner "sudo -n apt-get upgrade -y alacritty neovim" || error "Failed to upgrade packages"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        run_with_spinner "brew update" || error "Failed to update Homebrew"
        run_with_spinner "brew upgrade alacritty neovim" || error "Failed to upgrade packages"
    else
        log "WARNING" "Unsupported OS for package updates"
    fi
}

update_rust() {
    log "INFO" "Updating Rust..."
    run_with_spinner "rustup update" || error "Failed to update Rust"
}

update_zellij() {
    log "INFO" "Updating Zellij..."
    # shellcheck disable=SC2155
    local temp_file=$(mktemp)
    if [ "$VERBOSE" = true ]; then
        cargo install zellij 2>&1 | tee "$temp_file" | while IFS= read -r line; do
            echo -e "${GRAY}$line${RESET}"
        done
    else
        cargo install zellij > "$temp_file" 2>&1 &
        local pid=$!
        spinner $pid
        wait $pid
    fi
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Failed to update Zellij"
        cat "$temp_file"
    elif [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}Zellij updated successfully${RESET}"
    fi
    rm "$temp_file"
    return $exit_code
}

update_neovim_plugins() {
    log "INFO" "Updating Neovim plugins..."

    # Function to run Neovim command and check for errors
    run_nvim_command() {
        local command="$1"
        local message="$2"

        log "INFO" "$message"
        if ! run_with_spinner "nvim --headless +\"$command\" +qall"; then
            log "WARNING" "Failed to execute Neovim command: $command"
            return 1
        fi
        return 0
    }

    # Update vim-plug plugins
    run_nvim_command "if exists(':PlugUpdate') | PlugUpdate | else | echo 'vim-plug not installed' | endif" \
        "Updating vim-plug plugins..."

    # Upgrade vim-plug itself
    run_nvim_command "if exists(':PlugUpgrade') | PlugUpgrade | else | echo 'vim-plug not installed' | endif" \
        "Upgrading vim-plug..."

    # Update Treesitter parsers
    run_nvim_command "if exists(':TSUpdate') | TSUpdate | else | echo 'Treesitter not installed' | endif" \
        "Updating Treesitter parsers..."

    log "SUCCESS" "Neovim plugin update process completed."
}

# Define keybinding constants as arrays
KEYBINDINGS_LINUX=(
    "<Super>Return:Alacritty:alacritty"
    "<Super>F:Alacritty Fullscreen:wmctrl -r :ACTIVE: -b toggle,fullscreen"
)

KEYBINDINGS_MACOS=(
    "⌘⌥T:Alacritty:open -a Alacritty"
    "⌘⌥F:Alacritty Fullscreen:osascript -e 'tell application \"System Events\" to keystroke \"f\" using {command down, control down}'"
)
# Define a single keybinding for testing
KEYBINDING="<Super>Return:Alacritty:alacritty"




setup_keybinding_linux() {
    log "DEBUG" "Starting setup_keybinding_linux function"

    # Check if gsettings is available
    if ! command -v gsettings &> /dev/null; then
        log "ERROR" "gsettings command not found. Is GNOME installed?"
        return 1
    fi

    local keybinding_paths=()
    local KEYBINDING
    local binding
    local name
    local command
    local keybinding_path
    local set_name
    local set_command
    local set_binding
    local formatted_paths

    for i in "${!KEYBINDINGS_LINUX[@]}"; do
        KEYBINDING="${KEYBINDINGS_LINUX[i]}"
        IFS=":" read -r binding name command <<< "$KEYBINDING"
        keybinding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/"

        log "DEBUG" "Processing keybinding: $binding for $name (command: $command)"

        keybinding_paths+=("$keybinding_path")

        # Set the name
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" name "$name"
        log "DEBUG" "Set name: $name"

        # Set the command
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" command "$command"
        log "DEBUG" "Set command: $command"

        # Set the binding
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" binding "$binding"
        log "DEBUG" "Set binding: $binding"

        # Verify the settings
        set_name=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" name)
        set_command=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" command)
        set_binding=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$keybinding_path" binding)

        log "DEBUG" "Verification - Name: $set_name, Command: $set_command, Binding: $set_binding"

        if [[ "$set_name" != "'$name'" || "$set_command" != "'$command'" || "$set_binding" != "'$binding'" ]]; then
            log "ERROR" "Keybinding verification failed for $name. Please check the settings manually."
            return 1
        fi
    done

    # Set the custom keybindings
    formatted_paths=$(printf "'%s', " "${keybinding_paths[@]}")
    formatted_paths="[${formatted_paths%, }]"  # Remove trailing comma and space, then wrap in brackets
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$formatted_paths"
    log "DEBUG" "Set custom-keybindings: $formatted_paths"

    # Verify custom-keybindings setting
    local set_custom_keybindings
    set_custom_keybindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    log "DEBUG" "Verified custom-keybindings: $set_custom_keybindings"

    if [[ "$set_custom_keybindings" != "$formatted_paths" ]]; then
        log "ERROR" "Failed to set custom-keybindings paths"
        return 1
    fi

    log "SUCCESS" "All keybindings for Alacritty set up successfully on Linux."
}

#update_github_copilot() {
#    log "INFO" "Updating GitHub Copilot..."
#    local copilot_dir="$HOME/.config/nvim/pack/github/start/copilot.vim"
#
#    if [ -d "$copilot_dir" ]; then
#        cd "$copilot_dir" || error "Failed to change directory to $copilot_dir"
#
#        # Store the current commit hash
#        local old_hash=$(git rev-parse HEAD)
#
#        # Attempt to update
#        if run_with_spinner "git pull"; then
#            # Get the new commit hash
#            local new_hash=$(git rev-parse HEAD)
#
#            if [ "$old_hash" != "$new_hash" ]; then
#                log "SUCCESS" "GitHub Copilot updated successfully."
#            else
#                log "INFO" "GitHub Copilot is already up to date."
#            fi
#        else
#            error "Failed to update GitHub Copilot"
#        fi
#    else
#        log "WARNING" "GitHub Copilot not found. Please run the install function."
#    fi
#}

setup_keybinding_macos() {
    log "DEBUG" "Starting setup_keybinding_macos function"

    for keybinding in "${KEYBINDINGS_MACOS[@]}"; do
        log "DEBUG" "Processing keybinding: $keybinding"
        IFS=":" read -r binding name command <<< "$keybinding"

        log "DEBUG" "Setting up keybinding with defaults command"
        defaults write -g NSUserKeyEquivalents -dict-add "$name" "$binding"

        if [ $? -eq 0 ]; then
            log "DEBUG" "Set up keybinding: $binding for $name"
        else
            log "ERROR" "Failed to set up keybinding: $binding for $name"
            return 1
        fi
    done

    log "SUCCESS" "Keybindings for Alacritty set up on macOS."
    log "WARNING" "You may need to restart applications or log out and back in for changes to take effect."
}

setup_keybinding() {
    OS=$(uname -s)
    case $OS in
        Linux)
            setup_keybinding_linux
            ;;
        Darwin)
            setup_keybinding_macos
            ;;
        *)
            log "WARNING" "Unsupported OS for keybinding setup."
            ;;
    esac
}

# ==========================================================================
# Main Function
# ==========================================================================

main() {
    log "INFO" "Starting update process..."

    local steps=(
        "Backup configurations:backup_configs"
        "Update repository:update_repo"
        "Update configurations:update_configs"
        "Update packages:update_packages"
        "Update Rust:update_rust"
        "Update Zellij:update_zellij"
        "Update Neovim plugins:update_neovim_plugins"
        "Setup keybinding:setup_keybinding"
#        "Update GitHub Copilot:update_github_copilot"
    )

    for step in "${steps[@]}"; do
        IFS=":" read -r step_name step_function <<< "$step"
        if ! execute_step "$step_name" "$step_function"; then
            log "ERROR" "Update process failed at step: $step_name"
            echo "Your previous configuration has been backed up to: $BACKUP_DIR"
            echo "Please check the logs and try again."
            exit 1
        fi
    done

    log "SUCCESS" "Update completed successfully!"
    echo "Please restart your terminal for all changes to take effect."
    echo "If you encounter any issues, your previous configuration has been backed up to: $BACKUP_DIR"
}
# Parse command line arguments
while getopts "v" opt; do
    case $opt in
        v)
            VERBOSE=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

main