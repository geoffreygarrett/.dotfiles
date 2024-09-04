#!/bin/bash

set -euo pipefail

# Environment variables to check
declare -A env_vars=(
    ["EDITOR"]="nvim"
    ["SHELL"]="zsh"
)

# Check each environment variable
for var in "${!env_vars[@]}"; do
    if [ "${!var}" != "${env_vars[$var]}" ]; then
        echo "Environment variable $var is not set correctly."
        exit 1
    else
        echo "Environment variable $var is set correctly."
    fi
done
