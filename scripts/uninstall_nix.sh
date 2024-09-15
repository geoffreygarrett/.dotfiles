#!/usr/bin/env bash

set -uo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# shellcheck disable=SC2034
SHELL_FILES=(
  "/etc/bashrc"
  "/etc/profile.d/nix.sh"
  "/etc/zshrc"
  "/etc/bash.bashrc"
  "/etc/zsh/zshrc"
)

# shellcheck disable=SC2034
SHELL_BACKUP_FILES=(
  "/etc/bashrc.backup-before-nix"
  "/etc/zshrc.backup-before-nix"
  "/etc/bash.bashrc.backup-before-nix"
  "/etc/bash.bashrc.backup-before-nix"
  "/etc/zsh/zshrc.backup-before-nix"
)

# Function to log messages
log() {
  local level=$1
  local message=$2
  case $level in
    INFO) echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]${NC} $message" ;;
    WARN) echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]${NC} $message" ;;
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
  if [[ -e $1 ]]; then
    # shellcheck disable=SC2015
    rm -rf "$1" && log INFO "Removed: $1" || log WARN "Failed to remove: $1"
  fi
}

# Function to remove Nix-related lines from a file
remove_nix_lines() {
  local file="$1"
  if [[ -f $file ]]; then
    # shellcheck disable=SC2155
    local temp_file=$(mktemp)
    sed '/^# Nix$/,/^# End Nix$/d' "$file" >"$temp_file"
    if ! diff "$file" "$temp_file" >/dev/null 2>&1; then
      mv "$temp_file" "$file"
      log INFO "Removed Nix-related lines from $file"
    else
      rm "$temp_file"
      log INFO "No Nix-related lines found in $file"
    fi
  else
    log WARN "$file not found. Skipping."
  fi
}

# Function to remove Fish shell configurations
remove_fish_config() {
  local fish_dirs=("/etc/fish" "/usr/local/etc/fish" "/opt/homebrew/etc/fish" "/opt/local/etc/fish")
  for dir in "${fish_dirs[@]}"; do
    if [[ -d "$dir/conf.d" ]]; then
      safe_remove "$dir/conf.d/nix.fish"
    fi
  done
  log INFO "Removed Nix-related Fish shell configurations"
}

# Function to handle backup files
# Function to handle backup files
handle_backup() {
  local file="$1"
  local backup="${file}.backup-before-nix"
  # shellcheck disable=SC2155
  local timestamp=$(date +%Y%m%d%H%M%S)

  if [[ -f $backup ]]; then
    log INFO "Found existing backup for $file"

    # Rename the existing backup
    local old_backup="${backup}.old-${timestamp}"
    mv "$backup" "$old_backup"
    log INFO "Renamed existing backup to $old_backup"

    # Check if the current file contains Nix-related content
    if grep -q "Nix" "$file"; then
      log INFO "Current $file contains Nix-related content. Creating new backup."
      cp "$file" "$backup"
      log INFO "Created new backup: $backup"
      remove_nix_lines "$file"
    else
      log INFO "Current $file does not contain Nix-related content. No changes needed."
    fi
  else
    log INFO "No pre-Nix backup found for $file. Creating backup and removing Nix-related lines."
    cp "$file" "$backup" && log INFO "Created backup: $backup"
    remove_nix_lines "$file"
  fi
}

# Function to clean up shell configuration files
clean_shell_configs() {
  local shell_files=("$@")
  for file in "${shell_files[@]}"; do
    handle_backup "$file"
  done
}

# Function to uninstall Nix on Linux
uninstall_nix_linux() {
  log INFO "Uninstalling Nix on Linux..."

  # Stop and disable Nix daemon service
  if command -v systemctl >/dev/null 2>&1; then
    systemctl stop nix-daemon.service 2>/dev/null || log WARN "Failed to stop nix-daemon.service"
    systemctl disable nix-daemon.socket nix-daemon.service 2>/dev/null || log WARN "Failed to disable nix-daemon services"
    systemctl daemon-reload
    log INFO "Attempted to stop and disable Nix daemon service"
  fi

  # Remove Nix files and directories
  safe_remove /etc/nix
  safe_remove /etc/profile.d/nix.sh
  safe_remove /etc/tmpfiles.d/nix-daemon.conf
  safe_remove /nix
  safe_remove ~root/.nix-channels
  safe_remove ~root/.nix-defexpr
  safe_remove ~root/.nix-profile

  # Remove build users and their group
  for i in $(seq 1 32); do
    userdel nixbld"$i" 2>/dev/null || log WARN "Failed to remove user nixbld$i"
  done
  groupdel nixbld 2>/dev/null || log WARN "Failed to remove group nixbld"
  log INFO "Attempted to remove Nix build users and group"

  # Clean up shell configuration files
  clean_shell_configs "/etc/bash.bashrc" "/etc/bashrc" "/etc/profile" "/etc/zsh/zshrc" "/etc/zshrc" "/etc/profile.d/nix.sh"

  remove_fish_config
}

# Function to uninstall Nix on macOS
uninstall_nix_macos() {
  log INFO "Uninstalling Nix on macOS..."

  # Clean up shell configuration files
  clean_shell_configs "/etc/zshrc" "/etc/bashrc" "/etc/bash.bashrc" "/etc/profile" "/etc/profile.d/nix.sh"

  # Stop and remove Nix daemon services
  launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || log WARN "Failed to unload nix-daemon.plist"
  rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || log WARN "Failed to unload darwin-store.plist"
  rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist
  log INFO "Attempted to stop and remove Nix daemon services"

  # Remove nixbld group and users
  dscl . -delete /Groups/nixbld 2>/dev/null || log WARN "Failed to remove nixbld group"
  for u in $(dscl . -list /Users | grep _nixbld); do
    dscl . -delete /Users/"$u" 2>/dev/null || log WARN "Failed to remove user $u"
  done
  log INFO "Attempted to remove Nix build users and group"

  # Remove Nix Store from fstab
  sed -i.bak '/Nix Store/d' /etc/fstab || log WARN "Failed to remove Nix Store from fstab"
  log INFO "Attempted to remove Nix Store from fstab"

  # Remove nix from synthetic.conf
  if [[ -f /etc/synthetic.conf ]]; then
    sed -i.bak '/^nix/d' /etc/synthetic.conf || log WARN "Failed to remove nix from synthetic.conf"
    if [[ ! -s /etc/synthetic.conf ]]; then
      safe_remove /etc/synthetic.conf
    fi
    log INFO "Attempted to remove nix from synthetic.conf"
  fi

  # Remove Nix files and directories
  safe_remove /etc/nix
  safe_remove /var/root/.nix-profile
  safe_remove /var/root/.nix-defexpr
  safe_remove /var/root/.nix-channels
  safe_remove ~/.nix-profile
  safe_remove ~/.nix-defexpr
  safe_remove ~/.nix-channels

  # Remove Nix Store volume
  diskutil apfs deleteVolume /nix 2>/dev/null || log WARN "Failed to remove Nix Store volume"
  log INFO "Attempted to remove Nix Store volume"

  log WARN "An empty /nix directory may remain. It will disappear after a reboot."
}

# Function to uninstall Nix
uninstall_nix() {
  log INFO "Starting Nix uninstallation process..."

  if [[ "$(uname)" == "Darwin" ]]; then
    uninstall_nix_macos
  else
    uninstall_nix_linux
  fi

  # Remove Nix from PATH
  # shellcheck disable=SC2155
  export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/nix/store' | tr '\n' ':' | sed 's/:$//')

  log INFO "Nix uninstallation process completed."
  log WARN "Please restart your system to ensure all changes take effect."
  log WARN "You may need to manually remove any remaining Nix-related lines from your shell configuration files."
  log WARN "Check the created .uninstall-backup files if you need to restore any original configurations."
}

# Main function
main() {
  check_root
  uninstall_nix
}

# Run the main function
main
