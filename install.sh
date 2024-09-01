
#!/usr/bin/env bash

set -euo pipefail

# Default values
INSTALL_TYPE="multi"
FORCE_INSTALL=false
VERBOSE=false
CONFIGURE_SHELL=false
SHELL_TYPE=""

# Nix installation URL
NIX_INSTALL_URL="https://nixos.org/nix/install"

# Function to print usage
print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]
Options:
  -t, --type <type>     Installation type: 'multi' or 'single' (default: multi)
  -f, --force           Force installation even if Nix is already installed
  -v, --verbose         Enable verbose output
  -c, --configure-shell Configure shell for Nix (default: false)
  -s, --shell <shell>   Specify shell to configure (bash, zsh, fish)
  -h, --help            Print this help message
EOF
}

# Function to log messages
log() {
    local level=$1
    shift
    if [[ "$VERBOSE" == true || "$level" != "DEBUG" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    fi
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type) INSTALL_TYPE="$2"; shift 2 ;;
            -f|--force) FORCE_INSTALL=true; shift ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -c|--configure-shell) CONFIGURE_SHELL=true; shift ;;
            -s|--shell) SHELL_TYPE="$2"; shift 2 ;;
            -h|--help) print_usage; exit 0 ;;
            *) log "ERROR" "Unknown option: $1"; print_usage; exit 1 ;;
        esac
    done
}

# Function to check if Nix is already installed
is_nix_installed() {
    if command -v nix &> /dev/null; then
        log "INFO" "Nix is already installed. Version: $(nix --version)"
        return 0
    else
        log "INFO" "Nix is not installed."
        return 1
    fi
}

# Function to clean up previous Nix installation
cleanup_nix() {
    log "INFO" "Cleaning up previous Nix installation"
    
    # Stop and disable Nix daemon
    sudo systemctl stop nix-daemon.socket || true
    sudo systemctl stop nix-daemon.service || true
    sudo systemctl disable nix-daemon.socket || true
    sudo systemctl disable nix-daemon.service || true
    sudo systemctl daemon-reload

    # Restore backup files
    local backup_files=("/etc/bash.bashrc" "/etc/zsh/zshrc" "/etc/profile.d/nix.sh")
    for file in "${backup_files[@]}"; do
        if [[ -f "${file}.backup-before-nix" ]]; then
            sudo mv "${file}.backup-before-nix" "$file"
            log "INFO" "Restored ${file}"
        fi
    done

    # Remove Nix-related files and directories
    sudo rm -rf "/etc/nix" "/nix" "/root/.nix-profile" "/root/.nix-defexpr" "/root/.nix-channels" "/root/.local/state/nix" "/root/.cache/nix"
    rm -rf "$HOME/.nix-profile" "$HOME/.nix-defexpr" "$HOME/.nix-channels" "$HOME/.local/state/nix" "$HOME/.cache/nix"

    log "INFO" "Cleanup completed"
}

# Function to install Nix
install_nix() {
    local install_cmd="sh <(curl -L $NIX_INSTALL_URL) $([ "$INSTALL_TYPE" = "multi" ] && echo "--daemon" || echo "--no-daemon")"

    if is_nix_installed; then
        if [[ "$FORCE_INSTALL" == true ]]; then
            log "INFO" "Forcing reinstallation of Nix"
            cleanup_nix
        else
            log "INFO" "Nix is already installed. Use --force to reinstall."
            return
        fi
    fi

    log "INFO" "Installing Nix (Type: $INSTALL_TYPE)"
    if ! eval "$install_cmd"; then
        log "ERROR" "Nix installation failed"
        exit 1
    fi
    log "INFO" "Nix installation completed successfully"
}

# Function to configure shell for Nix
configure_shell() {
    local shell_config
    case $SHELL_TYPE in
        bash) shell_config="$HOME/.bashrc" ;;
        zsh) shell_config="$HOME/.zshrc" ;;
        fish) shell_config="$HOME/.config/fish/config.fish" ;;
        *) log "ERROR" "Unsupported shell: $SHELL_TYPE"; return 1 ;;
    esac

    if ! grep -q "Nix" "$shell_config"; then
        log "INFO" "Adding Nix configuration to $shell_config"
        cat << EOF >> "$shell_config"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
EOF
        log "INFO" "Nix configuration added to $shell_config"
    else
        log "INFO" "Nix configuration already present in $shell_config"
    fi
}

# Main execution
main() {
    parse_args "$@"
    install_nix

    if [[ "$CONFIGURE_SHELL" == true ]]; then
        if [[ -z "$SHELL_TYPE" ]]; then
            log "ERROR" "Shell type must be specified with --shell when using --configure-shell"
            exit 1
        fi
        configure_shell
    fi

    log "INFO" "Nix setup completed"
    if [[ "$CONFIGURE_SHELL" == true ]]; then
        log "INFO" "Please restart your shell or run 'source $shell_config' to apply the changes"
    else
        log "INFO" "Shell configuration was not performed. Use --configure-shell and --shell options if needed"
    fi
}

main "$@"
