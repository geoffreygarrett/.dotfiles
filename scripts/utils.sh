#!/bin/bash

# Script: utils.sh
# Description: Utility functions for terminal setup scripts

# ==========================================================================
# ANSI Color Codes
# ==========================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'
# shellcheck disable=SC2034
ORANGE='\033[38;5;208m'

# ==========================================================================
# Logging Functions
# ==========================================================================

# Logs messages with different severity levels
log() {
    local level=$1
    local message=$2
    # shellcheck disable=SC2155
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO")    local color=$BLUE ;;
        "WARNING") local color=$YELLOW ;;
        "ERROR")   local color=$RED ;;
        "SUCCESS") local color=$GREEN ;;
        "DEBUG")   local color=$GRAY ;;
        *)         local color=$RESET ;;
    esac

    echo -e "${BOLD}[${timestamp}]${RESET} ${color}${level}${RESET}: ${message}"
}

# Exits with an error message
error() {
    log "ERROR" "$1"
    exit 1
}

# ==========================================================================
# Spinner Functions
# ==========================================================================

# Displays a spinner while a command is running
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r [%c]  " "${spinstr:i:1}"
        sleep $delay
    done
    printf "\r      \r"  # Clear spinner on command completion or interruption
}

# Cleans up the spinner process
cleanup_spinner() {
    local spinner_pid=$1
    kill $spinner_pid 2>/dev/null
    wait $spinner_pid 2>/dev/null
    printf "\r      \r"  # Clear the line where the spinner was
}

# ==========================================================================
# Command Execution Functions
# ==========================================================================

# Runs a command with a spinner and logs the output
run_with_spinner() {
    local command="$1"
    local log_file=$(mktemp)
    local output=""

    # Start the command and spinner in the background
    eval "$command" > "$log_file" 2>&1 &
    local pid=$!
    spinner $pid &
    local spinner_pid=$!

    # Wait for the command to finish
    wait $pid
    local exit_code=$?

    # Cleanup the spinner
    cleanup_spinner $spinner_pid

    # Read and possibly display the output
    output=$(cat "$log_file")
    local max_lines=${MAX_VERBOSE_LINES:-10}  # Default to 10 if not set

    if [ "$VERBOSE" = true ]; then
        local lines=0
        while IFS= read -r line; do
            if [ $lines -lt "$max_lines" ]; then
                echo -e "${GRAY}$line${RESET}"
            elif [ $lines -eq "$max_lines" ]; then
                echo -e "${GRAY}...${RESET}"
            fi
            lines=$((lines+1))
        done <<< "$output"
    fi

    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Command failed: $command"
    elif [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}Command completed successfully${RESET}"
    fi

    rm "$log_file"
    return $exit_code
}

# Retries a command up to a maximum number of attempts
run_with_retry() {
    local max_attempts=3
    local attempt=1
    local delay=5

    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        else
            log "WARNING" "Attempt $attempt failed. Retrying in $delay seconds..."
            sleep $delay
            ((attempt++))
        fi
    done

    log "ERROR" "All attempts failed. Aborting."
    return 1
}

# ==========================================================================
# System Detection Functions
# ==========================================================================

# Detects the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

# ==========================================================================
# Step Execution Functions
# ==========================================================================
execute_step() {
    local step_name="$1"
    local step_function="$2"

    log "INFO" "Starting step: $step_name"
    if run_with_retry "$step_function"; then
        log "SUCCESS" "Completed step: $step_name"
        return 0
    else
        log "ERROR" "Failed step: $step_name after multiple attempts"
        return 1
    fi
}

# ==========================================================================
# File hashing and diff checking
# ==========================================================================
get_file_hash() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        sha256sum "$file" | awk '{print $1}'
    fi
}

files_are_different() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$dest" ]; then
        return 0  # Files are different if destination doesn't exist
    fi

    # shellcheck disable=SC2155
    local src_hash=$(get_file_hash "$src")
    # shellcheck disable=SC2155
    local dest_hash=$(get_file_hash "$dest")

    [ "$src_hash" != "$dest_hash" ]
}
