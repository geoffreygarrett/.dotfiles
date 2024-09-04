#!/bin/bash

set -euo pipefail

# Tools to check
tools=("nvim" "zellij" "alacritty")

# Check each tool
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is not installed."
        exit 1
    else
        echo "$tool is installed correctly."
    fi
done
