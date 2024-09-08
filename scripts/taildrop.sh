#!/bin/bash

# Configuration
NEW_TAILDROP_PATH="/path/to/your/new/location"
BACKUP_SUFFIX=".bak-$(date +%Y%m%d%H%M%S)"

# Detect OS and set default Taildrop path
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    DEFAULT_TAILDROP_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/TailscaleFiles"
    OS_TYPE="macOS"
else
    # Assume Linux
    DEFAULT_TAILDROP_PATH="/var/lib/tailscale/files"
    OS_TYPE="Linux"
fi

# Function to print usage
print_usage() {
    echo "Usage: $0 [change|rollback]"
    echo "  change   - Change Taildrop folder to the new location"
    echo "  rollback - Revert Taildrop folder to the original location"
}

# Function to change Taildrop folder
change_taildrop_folder() {
    if [ ! -d "$DEFAULT_TAILDROP_PATH" ]; then
        echo "Error: Default Taildrop folder not found."
        exit 1
    fi

    # Create new directory if it doesn't exist
    mkdir -p "$NEW_TAILDROP_PATH"

    # Move contents and create symlink
    mv "$DEFAULT_TAILDROP_PATH" "${DEFAULT_TAILDROP_PATH}${BACKUP_SUFFIX}"
    ln -s "$NEW_TAILDROP_PATH" "$DEFAULT_TAILDROP_PATH"

    echo "Taildrop folder changed to $NEW_TAILDROP_PATH"
    echo "Original folder backed up to ${DEFAULT_TAILDROP_PATH}${BACKUP_SUFFIX}"
}

# Function to rollback changes
rollback_changes() {
    if [ ! -L "$DEFAULT_TAILDROP_PATH" ]; then
        echo "Error: No symlink found at $DEFAULT_TAILDROP_PATH. Nothing to rollback."
        exit 1
    fi

    # Find the most recent backup
    LATEST_BACKUP=$(ls -d ${DEFAULT_TAILDROP_PATH}.bak-* 2>/dev/null | sort -r | head -n1)

    if [ -z "$LATEST_BACKUP" ]; then
        echo "Error: No backup found to rollback to."
        exit 1
    fi

    # Remove symlink and restore original folder
    rm "$DEFAULT_TAILDROP_PATH"
    mv "$LATEST_BACKUP" "$DEFAULT_TAILDROP_PATH"

    echo "Taildrop folder rolled back to original location: $DEFAULT_TAILDROP_PATH"
}

# Main script logic
if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

echo "Detected OS: $OS_TYPE"
echo "Default Taildrop path: $DEFAULT_TAILDROP_PATH"

case "$1" in
    change)
        change_taildrop_folder
        ;;
    rollback)
        rollback_changes
        ;;
    *)
        print_usage
        exit 1
        ;;
esac