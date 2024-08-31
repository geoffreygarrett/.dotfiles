#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default GitHub username (can be overridden by environment variable)
GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="cross-platform-terminal-setup"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Print usage information
usage() {
  echo "Usage: bash <(curl -sL <URL_TO_THIS_SCRIPT>)"
}

# Install Ansible and Git if not already installed
install_dependencies() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y ansible git curl
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Ensure Homebrew is installed
    if ! command -v brew &> /dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install ansible git curl
  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi
}

# Clone the playbook repository if not already present
clone_repository() {
  if [[ ! -d "$REPO_NAME" ]]; then
    git clone "$REPO_URL"
  else
    cd "$REPO_NAME"
    git pull
    cd ..
  fi
}

# Run the Ansible playbook
run_playbook() {
  cd "$REPO_NAME"
  ansible-playbook playbook.yml --tags "setup"
}

# Main function
main() {
  install_dependencies
  clone_repository
  run_playbook
  echo "Setup completed successfully!"
}

# Run the script
main
