#!/usr/bin/env bash

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    local level=$1
    local message=$2
    case $level in
        INFO)  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]${NC} $message" ;;
        WARN)  echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]${NC} $message" ;;
        ERROR) echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR]${NC} $message" ;;
    esac
}

# Function to check if we're running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log ERROR "This script must be run as root. Please use sudo."
        exit 1
    fi
}

# Function to safely remove a file or directory
safe_remove() {
    if [[ -e "$1" ]]; then
        rm -rf "$1" && log INFO "Removed: $1" || log ERROR "Failed to remove: $1"
    fi
}

# Function to safely revert a file
revert_file() {
    local file="$1"
    local backup="${file}.backup-before-nix"
    if [[ -f "$backup" ]]; then
        if diff "$file" "$backup" >/dev/null 2>&1; then
            log INFO "No changes in $file. Removing backup."
            rm "$backup"
        else
            log INFO "Reverting $file"
            mv "$backup" "$file"
        fi
    elif [[ -f "$file" ]]; then
        log WARN "$file exists but no backup found. Check manually: $file"
    else
        log INFO "Neither $file nor its backup exist. Skipping."
    fi
}

# Function to remove Nix-related lines from a file
remove_nix_lines() {
    local file="$1"
    if [[ -f "$file" ]]; then
        sed -i.bak '/nix/d' "$file" && log INFO "Removed Nix-related lines from $file"
        if ! diff "$file" "${file}.bak" >/dev/null 2>&1; then
            log INFO "Changes made to $file. Backup saved as ${file}.bak"
        else
            rm "${file}.bak"
        fi
    fi
}

# Function to uninstall Nix
uninstall_nix() {
    log INFO "Starting Nix uninstallation process..."

    # Stop Nix-related services
    if command -v systemctl >/dev/null 2>&1; then
        systemctl stop nix-daemon.service 2>/dev/null || true
        systemctl disable nix-daemon.socket nix-daemon.service 2>/dev/null || true
        systemctl daemon-reload
    elif command -v launchctl >/dev/null 2>&1; then
        launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
        launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true
    fi

    # Remove Nix files and directories
    safe_remove /nix
    safe_remove /etc/nix
    safe_remove /etc/profile.d/nix.sh
    safe_remove /etc/tmpfiles.d/nix-daemon.conf
    safe_remove "$HOME/.nix-channels"
    safe_remove "$HOME/.nix-defexpr"
    safe_remove "$HOME/.nix-profile"
    safe_remove "/root/.nix-channels"
    safe_remove "/root/.nix-defexpr"
    safe_remove "/root/.nix-profile"

    # Remove Nix configuration files
    safe_remove /etc/nix
    safe_remove "$HOME/.config/nixpkgs"
    safe_remove "$HOME/.config/nix"

    # Revert or clean up shell configuration files
    local shell_files=("/etc/bash.bashrc" "/etc/bashrc" "/etc/profile" "/etc/zsh/zshrc" "/etc/zshrc" "/etc/profile.d/nix.sh")
    for file in "${shell_files[@]}"; do
        revert_file "$file"
        remove_nix_lines "$file"
    done

    # Remove Nix-related users and groups
    if command -v userdel >/dev/null 2>&1; then
        for i in $(seq 1 32); do
            userdel "nixbld$i" 2>/dev/null || true
        done
        groupdel nixbld 2>/dev/null || true
    elif command -v dscl >/dev/null 2>&1; then
        dscl . -delete /Groups/nixbld 2>/dev/null || true
        for u in $(dscl . -list /Users | grep _nixbld); do
            dscl . -delete /Users/"$u" 2>/dev/null || true
        done
    fi

    # macOS-specific cleanup
    if [[ "$(uname)" == "Darwin" ]]; then
        safe_remove /Library/LaunchDaemons/org.nixos.nix-daemon.plist
        safe_remove /Library/LaunchDaemons/org.nixos.darwin-store.plist
        sed -i.bak '/Nix Store/d' /etc/fstab
        if [[ -f /etc/synthetic.conf ]]; then
            sed -i.bak '/^nix/d' /etc/synthetic.conf
            if [[ ! -s /etc/synthetic.conf ]]; then
                safe_remove /etc/synthetic.conf
            fi
        fi
        diskutil apfs deleteVolume /nix 2>/dev/null || true
    fi

    # Remove Nix from PATH
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v '/nix/store' | tr '\n' ':' | sed 's/:$//')

    log INFO "Nix uninstallation process completed."
    log WARN "Please restart your system to ensure all changes take effect."
    log WARN "You may need to manually remove any remaining Nix-related lines from your shell configuration files."
}

# Main function
main() {
    check_root
    uninstall_nix
}

# Run the main function
main