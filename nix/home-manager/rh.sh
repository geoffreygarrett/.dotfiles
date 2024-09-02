#!/bin/bash

  # Function to check if the current directory or specified path has a flake.nix
  check_flake() {
    local dir="$1"
    if [[ -f "$dir/flake.nix" ]]; then
      echo "$dir"
      return 0
    fi
    return 1
  }

  # Function to check if a directory is a GitHub repository
  is_github_repo() {
    local dir="$1"
    (cd "$dir" && git remote get-url origin 2>/dev/null | grep -q 'github.com')
  }

  # Check current directory
  if check_flake "$PWD"; then
    FLARE_DIR="$PWD"
  else
    # Check predefined directory
    if check_flake "$HOME/Repositories/celestial-blueprint"; then
      FLARE_DIR="$HOME/Repositories/celestial-blueprint"
    else
      # Check if current directory is a GitHub repo and use its parent
      if is_github_repo "$PWD"; then
        FLARE_DIR=$(dirname "$PWD")
        if check_flake "$FLARE_DIR"; then
          echo "$FLARE_DIR"
          exit 0
        fi
      fi
      echo "flake.nix not found"
      exit 1e
    fi
  fi

  # Run the nix command with the determined flake directory
  nix run "$FLARE_DIR#homeConfigurations.$(whoami)@$(echo $(hostname | cut -d '.' -f 1) | tr '[:upper:]' '[:lower:]').activationPackage" && exec zsh
