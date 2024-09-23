#!/usr/bin/env bash
set -e

# Function to get the flake directory
get_flake_dir() {
    local dir="$PWD"
    while [[ $dir != "/" ]]; do
        if [[ -e "$dir/flake.nix" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "Error: Could not find flake.nix in any parent directory." >&2
    return 1
}

# Get the flake directory
FLAKE_DIR=$(get_flake_dir)

# Get user and hostname
USERNAME=$(whoami)
HOSTNAME=$(hostname | cut -d '.' -f 1 | tr '[:upper:]' '[:lower:]')

FULL_CONFIG="$USERNAME@$HOSTNAME"
echo "Running Home Manager switch for $FULL_CONFIG..."

# Run the nix command with the determined flake directory
if nix run --quiet "$FLAKE_DIR#homeConfigurations.$FULL_CONFIG.activationPackage" >/dev/null 2>&1; then
    echo "Home Manager switch completed successfully."
else
    echo "Error occurred during Home Manager switch. Full output:"
    nix run --impure "$FLAKE_DIR#homeConfigurations.$FULL_CONFIG.activationPackage"
    exit 1
fi

echo "Restarting shell..."
exec "$SHELL"
