#!/bin/bash

# Script: install.sh
# Description: Installs and configures terminal setup for Linux and macOS
# Usage: sudo bash install.sh [-v]

set -e

# ==========================================================================
# Initialization
# ==========================================================================

# Check if script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Source the log utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/utils.sh"

REPO_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
LOGFILE="/var/log/terminal_setup_log.txt"
ACTION_STACK=()
VERBOSE=false
MAX_VERBOSE_LINES=10

# ==========================================================================
# Helper Functions
# ==========================================================================

push_action() {
    ACTION_STACK+=("$1")
}

#rollback() {
#    log "ERROR" "Rolling back due to error: $1"
#    for ((i=${#ACTION_STACK[@]}-1; i>=0; i--)); do
#        eval "${ACTION_STACK[i]}" || log "WARNING" "Rollback action failed: ${ACTION_STACK[i]}"
#    done
#    log "INFO" "Rollback complete"
#    exit 1
#}


rollback() {
    log "ERROR" "Rolling back due to error: $1"
    for ((i=${#ACTION_STACK[@]}-1; i>=0; i--)); do
        eval "${ACTION_STACK[i]}" || log "WARNING" "Rollback action failed: ${ACTION_STACK[i]}"
    done

    if [ -d "$BACKUP_DIR" ]; then
        log "INFO" "Restoring backups..."
        cp -r "$BACKUP_DIR/." "$HOME/" || log "WARNING" "Failed to restore some backups"
        log "INFO" "Backups restored from $BACKUP_DIR"
    fi

    log "INFO" "Rollback complete"
    exit 1
}

# Function to check and remove apt locks
remove_apt_locks() {
    log "INFO" "Checking for apt locks..."
    for lock in "/var/lib/dpkg/lock" "/var/lib/apt/lists/lock" "/var/cache/apt/archives/lock"
    do
        if sudo fuser $lock &>/dev/null; then
            log "WARNING" "Lock $lock is being held. Attempting to remove..."
            sudo rm -f $lock
        fi
    done
    log "INFO" "Apt locks check complete"
}

# ==========================================================================
# Installation Functions
# ==========================================================================

install_packages() {
    OS=$(detect_os)
    case $OS in
        linux)
            log "INFO" "Updating package lists..."
            remove_apt_locks
            run_with_spinner "sudo apt-get update" || return 1
            log "INFO" "Installing packages..."
            run_with_spinner "sudo apt-get install -y alacritty neovim curl build-essential unzip wmctrl" || return 1
            push_action "sudo apt-get remove -y alacritty neovim curl build-essential unzip wmctrl"
            ;;
        macos)
            log "INFO" "Installing packages..."
            run_with_spinner "brew install alacritty neovim unzip wmctrl" || return 1
            push_action "brew uninstall alacritty neovim unzip wmctrl"
            ;;
        *)
            log "ERROR" "Unsupported OS. This script is for Linux and macOS."
            return 1
            ;;
    esac
    log "SUCCESS" "Packages installed"
}

install_rust() {
    log "INFO" "Installing Rust..."
    if ! command -v rustc &> /dev/null; then
        run_with_spinner "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" || return 1
        # Source cargo environment
        source $HOME/.cargo/env
        run_with_spinner "rustup component add rust-analyzer" || return 1
        push_action "rustup self uninstall -y"
    else
        log "INFO" "Rust is already installed. Updating..."
        run_with_spinner "rustup update" || return 1
    fi
    log "SUCCESS" "Rust installed/updated"
}

install_zellij() {
    log "INFO" "Installing Zellij..."
    # Ensure cargo is in PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    if ! command -v cargo &> /dev/null; then
        log "ERROR" "Cargo is not available. Please ensure Rust is properly installed."
        return 1
    fi
    run_with_spinner "cargo install --locked zellij" || return 1
    push_action "cargo uninstall zellij"
    log "SUCCESS" "Zellij installed"
}

install_vim_plug() {
    log "INFO" "Installing vim-plug..."
    PLUG_VIM="/home/$SUDO_USER/.local/share/nvim/site/autoload/plug.vim"
    run_with_spinner "curl -fLo '$PLUG_VIM' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" || return 1

    # Create a minimal init.vim to initialize vim-plug
    INIT_VIM="/home/$SUDO_USER/.config/nvim/init.vim"
    mkdir -p "$(dirname "$INIT_VIM")"
    cat << EOF > "$INIT_VIM"
call plug#begin()
" Plugins go here
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
EOF

    chown $SUDO_USER:$SUDO_USER "$INIT_VIM"

    push_action "rm -f '$PLUG_VIM' '$INIT_VIM'"
    log "SUCCESS" "vim-plug installed and initialized"
}

install_lazyvim() {
    log "INFO" "Installing LazyVim..."
    if [ ! -d "$HOME/.config/nvim/lazy" ]; then
        run_with_spinner "git clone https://github.com/folke/lazy.nvim.git ~/.config/nvim/lazy/lazy.nvim" || error "Failed to install lazy.nvim"
    fi
    log "SUCCESS" "LazyVim installed"
}

#create_symlinks() {
#    log "INFO" "Creating symlinks..."
#    mkdir -p ~/.config/alacritty ~/.config/zellij ~/.config/nvim ~/.config/nushell
#
#    ln -sf "$REPO_DIR/config/alacritty" ~/.config/alacritty || return 1
#    ln -sf "$REPO_DIR/config/zellij" ~/.config/zellij || return 1
#    ln -sf "$REPO_DIR/config/nvim" ~/.config/nvim || return 1
#    ln -sf "$REPO_DIR/config/nushell" ~/.config/nushell || return 1
#
#    push_action "rm -f ~/.config/alacritty ~/.config/zellij ~/.config/nvim ~/.config/nushell"
#    log "SUCCESS" "Symlinks created"
#}

create_symlinks() {
    log "INFO" "Creating symlinks..."

    # Ensure backup directory exists
    BACKUP_DIR="$HOME/.terminal_setup_backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Function to backup existing file or directory
    backup_if_exists() {
        local target="$1"
        if [ -e "$target" ]; then
            local backup_path="$BACKUP_DIR/$(basename "$target")"
            cp -r "$target" "$backup_path" || return 1
            log "INFO" "Backed up $target to $backup_path"
            push_action "rm -rf \"$target\" && mv \"$backup_path\" \"$target\""
        fi
    }

    # Function to create a symlink if the target is different
    create_symlink() {
        local src="$1"
        local dest="$2"

        backup_if_exists "$dest" || return 1

        # Check if the target already exists and is a symlink
        if [ -L "$dest" ]; then
            local target_path
            target_path=$(readlink -f "$dest")
            if [ "$target_path" != "$src" ]; then
                ln -sf "$src" "$dest" || return 1
                log "INFO" "Updated symlink: $dest -> $src"
            else
                log "INFO" "Symlink already up to date: $dest"
            fi
        else
            ln -sf "$src" "$dest" || return 1
            log "INFO" "Created symlink: $dest -> $src"
        fi
    }

    # Create necessary directories
    mkdir -p ~/.config/alacritty ~/.config/zellij ~/.config/nvim ~/.config/nushell

    # Create symlinks for each config directory
    create_symlink "$REPO_DIR/config/alacritty" ~/.config/alacritty || return 1
    create_symlink "$REPO_DIR/config/zellij" ~/.config/zellij || return 1
    create_symlink "$REPO_DIR/config/nvim" ~/.config/nvim || return 1
    create_symlink "$REPO_DIR/config/nushell" ~/.config/nushell || return 1

    log "SUCCESS" "Symlinks created"
}


install_neovim_plugins() {
    log "INFO" "Installing Neovim plugins..."

    # Ensure vim-plug is installed
    PLUG_VIM="/home/$SUDO_USER/.local/share/nvim/site/autoload/plug.vim"
    if [ ! -f "$PLUG_VIM" ]; then
        log "INFO" "vim-plug not found, installing..."
        run_with_spinner "curl -fLo '$PLUG_VIM' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" || return 1
    fi

    # Ensure a minimal init.vim is present to use vim-plug
    INIT_VIM="/home/$SUDO_USER/.config/nvim/init.vim"
    if [ ! -f "$INIT_VIM" ]; then
        log "INFO" "Creating minimal init.vim for plugin installation..."
        mkdir -p "$(dirname "$INIT_VIM")"
        cat << EOF > "$INIT_VIM"
call plug#begin('~/.local/share/nvim/site/autoload/plug.vim')
Plug 'nvim-treesitter/nvim-treesitter'
call plug#end()
EOF
        chown $SUDO_USER:$SUDO_USER "$INIT_VIM"
    fi

    # Run nvim in a non-headless mode to debug if needed
    log "INFO" "Verifying Neovim configuration..."
    run_with_spinner "nvim --headless +'echo \"vim-plug initialized successfully\"' +qall" || return 1

    # Install plugins
    log "INFO" "Running PlugInstall..."
    run_with_spinner "nvim --headless +PlugInstall +qall" || return 1

    log "INFO" "Running TSUpdate..."
    run_with_spinner "nvim --headless +TSUpdate +qall" || return 1

    # Add cleanup action
    push_action "rm -rf /home/$SUDO_USER/.local/share/nvim/plugged"

    log "SUCCESS" "Neovim plugins installed"
}



#install_github_copilot() {
#    log "INFO" "Installing GitHub Copilot..."
#    local copilot_dir="$HOME/.config/nvim/pack/github/start/copilot.vim"
#
#    if [ -d "$copilot_dir" ]; then
#        log "INFO" "GitHub Copilot is already installed. Running update instead."
#        update_github_copilot
#    else
#        mkdir -p "$HOME/.config/nvim/pack/github/start"
#        if run_with_spinner "git clone https://github.com/github/copilot.vim.git $copilot_dir"; then
#            log "SUCCESS" "GitHub Copilot installed successfully."
#        else
#            error "Failed to install GitHub Copilot"
#        fi
#    fi
#}

install_jetbrains_mono() {
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    FONT_DIR="/usr/local/share/fonts/JetBrainsMono"

    log "INFO" "Downloading JetBrains Mono Nerd Font..."
    run_with_spinner "curl -L -o /tmp/JetBrainsMono.zip $FONT_URL" || return 1

    log "INFO" "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR" || return 1
    run_with_spinner "unzip -o /tmp/JetBrainsMono.zip -d $FONT_DIR" || return 1
    run_with_spinner "fc-cache -fv" || return 1
    push_action "rm -rf '$FONT_DIR'"

    log "SUCCESS" "JetBrains Mono Nerd Font installed"
}


install_nushell() {
    log "INFO" "Installing Nushell..."

    OS=$(detect_os)
    case $OS in
        linux)
            if command -v cargo &> /dev/null; then
                log "INFO" "Installing Nushell via Cargo..."
                run_with_spinner "cargo install nu" || exit 1
            else
                log "INFO" "Installing Nushell via package manager..."
                run_with_spinner "sudo apt-get install nushell -y" || exit 1
            fi
            ;;
        macos)
            log "INFO" "Installing Nushell via Homebrew..."
            run_with_spinner "brew install nushell" || exit 1
            ;;
        *)
            log "ERROR" "Unsupported OS for Nushell installation"
            exit 1
            ;;
    esac

    log "SUCCESS" "Nushell installed"
}

# ==========================================================================
# Main Function
# ==========================================================================

main() {
    log "INFO" "Starting installation"

    local steps=(
        "Install packages:install_packages"
        "Install Rust:install_rust"
        "Install Nushell:install_nushell"
        "Install Zellij:install_zellij"
        "Install vim-plug:install_vim_plug"
        "Install LazyVim:install_lazyvim"
        "Create symlinks:create_symlinks"
        "Install Neovim plugins:install_neovim_plugins"
        "Install JetBrains Mono:install_jetbrains_mono"
#        "Install GitHub Copilot:install_github_copilot"
    )

    for step in "${steps[@]}"; do
        IFS=":" read -r step_name step_function <<< "$step"
        if ! execute_step "$step_name" "$step_function"; then
            rollback "Failed to $step_name"
        fi
    done

    # Check if wmctrl is installed
    if ! command -v wmctrl &> /dev/null; then
        log "ERROR" "wmctrl is not installed. Please check the package installation step."
        rollback "wmctrl installation failed"
    fi

    log "SUCCESS" "Installation completed successfully"
    echo "Setup complete! Please restart your terminal for all changes to take effect."
    echo "You may need to run 'source ~/.cargo/env' or restart your shell to use Rust and Zellij."
}

# ==========================================================================
# Script Execution
# ==========================================================================

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

# Run main function
main || rollback "Installation failed"