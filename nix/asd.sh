#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

update_status() {
  local prefix="$1"
  local status="$2"
  local color="$3"
  printf "\r${color}%-100s${NC}" "$prefix $status"
}

total_steps=31
status_messages=(
  "Compiling headers"
  "Linking libraries"
  "Optimizing code"
  "Generating documentation"
  "Running unit tests"
)

for i in {1..5}; do
  status="${status_messages[$i-1]}"
  for j in {1..31}; do
    prefix="[$i/$j/31 built, 0.0 MiB DL]"
    case $i in
      1) color=$RED ;;
      2) color=$GREEN ;;
      3) color=$YELLOW ;;
      4) color=$BLUE ;;
      5) color=$NC ;;
    esac
    update_status "$prefix" "$status" "$color"
    sleep 0.1  # Simulate some processing time
  done
done

echo -e "\n${GREEN}Done!${NC}"  # Move to next line when finished