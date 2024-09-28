#!/bin/bash

set -euo pipefail

# Config files to check
configs=("$HOME/.config/nvim/init.vim" "$HOME/.config/zellij/config.toml")

# Check each config file
for config in "${configs[@]}"; do
  if [ ! -f "$config" ]; then
    echo "Configuration file $config is missing."
    exit 1
  else
    echo "Configuration file $config is set up correctly."
  fi
done
