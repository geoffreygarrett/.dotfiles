#!/usr/bin/env bash

set -euo pipefail

# Configuration
CONFIG_REPO="https://github.com/geoffreygarrett/cross-platform-terminal-setup.git"
CONFIG_DIR="$HOME/.config"
DEV_CONFIG_DIR="$HOME/.config-dev"

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version; then
            echo "wsl"
        else
            echo "linux"
        fi
    else
        echo "unsupported"
    fi
}

# Function to install Nix
install_nix() {
    if ! command -v nix &> /dev/null; then
        echo "Installing Nix..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
        source /etc/profile
    else
        echo "Nix is already installed."
    fi
}

# Function to install Home Manager
install_home_manager() {
    if ! command -v home-manager &> /dev/null; then
        echo "Installing Home Manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
    else
        echo "Home Manager is already installed."
    fi
}

# Function to clone or update config repository
# Function to clone or update config repository
update_config_repo() {
    local target_dir="$1"
    local temp_dir="/tmp/nix-config-temp"

    if [ -d "$target_dir/.git" ]; then
        echo "Updating existing configuration in $target_dir..."
        cd "$target_dir"
        git pull
    elif [ -d "$target_dir" ] && [ "$(ls -A $target_dir)" ]; then
        echo "The directory $target_dir already exists and is not empty."
        echo "Options:"
        echo "1. Backup existing directory and clone new config"
        echo "2. Merge new config with existing directory"
        echo "3. Skip configuration update"
        read -p "Choose an option (1/2/3): " -n 1 -r
        echo
        case $REPLY in
            1)
                backup_dir="${target_dir}-backup-$(date +%Y%m%d%H%M%S)"
                echo "Backing up $target_dir to $backup_dir"
                mv "$target_dir" "$backup_dir"
                echo "Cloning configuration repository to $target_dir..."
                git clone "$CONFIG_REPO" "$target_dir"
                ;;
            2)
                echo "Cloning new configuration to temporary directory..."
                git clone "$CONFIG_REPO" "$temp_dir"
                echo "Merging new configuration with existing directory..."
                rsync -av --ignore-existing "$temp_dir/" "$target_dir/"
                echo "Cleaning up temporary directory..."
                rm -rf "$temp_dir"
                echo "Merge complete. Please review changes in $target_dir"
                ;;
            3)
                echo "Skipping configuration update."
                return 0
                ;;
            *)
                echo "Invalid option. Skipping configuration update."
                return 1
                ;;
        esac
    else
        echo "Cloning configuration repository to $target_dir..."
        git clone "$CONFIG_REPO" "$target_dir"
    fi
}

# Function to apply Home Manager configuration
apply_home_manager() {
    local config_dir="$1"
    echo "Applying Home Manager configuration from $config_dir..."
    home-manager switch -f "$config_dir/home.nix"
}

# Function to update Nix channels and Home Manager
update_nix() {
    echo "Updating Nix channels..."
    nix-channel --update
    echo "Updating Home Manager..."
    home-manager update
}

# Function to perform a full sync
full_sync() {
    local config_dir="$1"
    update_config_repo "$config_dir"
    update_nix
    apply_home_manager "$config_dir"
}

# Function to test configuration
test_config() {
    echo "Testing configuration..."
    update_config_repo "$DEV_CONFIG_DIR"
    home-manager build -f "$DEV_CONFIG_DIR/home.nix"
    echo "Test build successful. To apply this configuration, use: $0 apply-test"
}

# Function to apply test configuration
apply_test_config() {
    echo "Applying test configuration..."
    apply_home_manager "$DEV_CONFIG_DIR"
}

# Main execution
main() {
    local OS=$(detect_os)
    if [ "$OS" == "unsupported" ]; then
        echo "Unsupported OS"
        exit 1
    fi

    # Check if an argument is provided
    if [ $# -eq 0 ]; then
        echo "No command provided."
        show_usage
        exit 1
    fi

    case "$1" in
        install)
            install_nix
            install_home_manager
            if ! update_config_repo "$CONFIG_DIR"; then
                echo "Failed to update configuration. Exiting."
                exit 1
            fi
            apply_home_manager "$CONFIG_DIR"
            ;;
        update)
            update_nix
            ;;
        sync)
            if ! update_config_repo "$CONFIG_DIR"; then
                echo "Failed to update configuration. Exiting."
                exit 1
            fi
            update_nix
            apply_home_manager "$CONFIG_DIR"
            ;;
        test)
            if ! update_config_repo "$DEV_CONFIG_DIR"; then
                echo "Failed to update test configuration. Exiting."
                exit 1
            fi
            test_config
            ;;
        apply-test)
            apply_test_config
            ;;
        *)
            echo "Invalid command: $1"
            show_usage
            exit 1
            ;;
    esac

    echo "Operation completed successfully!"
}

# Function to show usage information
show_usage() {
    echo "Usage: $0 {install|update|sync|test|apply-test}"
    echo "  install:    First-time setup of Nix, Home Manager, and configs"
    echo "  update:     Update Nix channels and Home Manager"
    echo "  sync:       Update config repo, Nix, Home Manager, and apply changes"
    echo "  test:       Test configuration in a separate directory"
    echo "  apply-test: Apply the test configuration"
}

# Call main function with all command-line arguments
main "$@"