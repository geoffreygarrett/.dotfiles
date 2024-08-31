#!/bin/bash

REPO_URL="https://github.com/geoffreygarrett/cross-platform-terminal-setup.git"
REPO_DIR="$HOME/cross-platform-terminal-setup"

# Clone or pull the repository
if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    git pull
else
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Run the installation script
./install.sh