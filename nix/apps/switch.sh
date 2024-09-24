#!/bin/sh -e

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

OS_TYPE=$(uname -s)
SYSTEM=$(uname -m)

if [ "$OS_TYPE" = "Linux" ]; then
  case "$SYSTEM" in
    x86_64)
      SYSTEM_TARGET="x86_64-linux"
      ;;
    aarch64)
      SYSTEM_TARGET="aarch64-linux"
      ;;
    *)
      echo -e "${RED}Unsupported Linux architecture: $SYSTEM${NC}"
      exit 1
      ;;
  esac

  # Check if a host-specific configuration exists
  if [ -e "./nix/hosts/nixos/$HOSTNAME" ]; then
    FLAKE_TARGET="$HOSTNAME"
    echo -e "${GREEN}Using host-specific configuration for $HOSTNAME${NC}"
  else
    FLAKE_TARGET="$SYSTEM_TARGET"
    echo -e "${YELLOW}No host-specific configuration found. Using system-specific configuration: $SYSTEM_TARGET${NC}"
  fi

  echo -e "${YELLOW}Starting Linux rebuild...${NC}"
  # We pass SSH from user to root so root can download secrets from our private Github
  sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK /run/current-system/sw/bin/nixos-rebuild switch --flake .#$FLAKE_TARGET "$@"

elif [ "$OS_TYPE" = "Darwin" ]; then
  case "$SYSTEM" in
    x86_64)
      SYSTEM_TARGET="x86_64-darwin"
      ;;
    arm64)
      SYSTEM_TARGET="aarch64-darwin"
      ;;
    *)
      echo -e "${RED}Unsupported Darwin architecture: $SYSTEM${NC}"
      exit 1
      ;;
  esac

  # Check if a host-specific configuration exists
  if [ -e "./nix/hosts/darwin/$HOSTNAME" ]; then
    FLAKE_TARGET="$HOSTNAME"
    echo -e "${GREEN}Using host-specific configuration for $HOSTNAME${NC}"
  else
    FLAKE_TARGET="$SYSTEM_TARGET"
    echo -e "${YELLOW}No host-specific configuration found. Using system-specific configuration: $SYSTEM_TARGET${NC}"
  fi

  FLAKE_SYSTEM="darwinConfigurations.${FLAKE_TARGET}.system"

  export NIXPKGS_ALLOW_UNFREE=1

  echo -e "${YELLOW}Starting Darwin build...${NC}"
  nix --extra-experimental-features 'nix-command flakes' build .#$FLAKE_SYSTEM "$@"

  echo -e "${YELLOW}Switching to new generation...${NC}"
  ./result/sw/bin/darwin-rebuild switch --flake .#${FLAKE_TARGET} "$@"

  echo -e "${YELLOW}Cleaning up...${NC}"
  unlink ./result

else
  echo -e "${RED}Unsupported operating system: $OS_TYPE${NC}"
  exit 1
fi

echo -e "${GREEN}Switch to new generation complete!${NC}"
