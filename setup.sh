#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default GitHub username and repository name (can be overridden by environment variables)
GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="${REPO_NAME:-cross-platform-terminal-setup}"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
SETUP_TAG="${SETUP_TAG:-setup}"

# Print usage information
usage() {
  echo "Usage: bash <(curl -sL https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/main/setup.sh)"
  echo "You can override the default GitHub username and repository name by setting the GITHUB_USERNAME and REPO_NAME environment variables."
}

# Install Ansible and Git if not already installed
install_dependencies() {
  echo "Installing dependencies..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v ansible &> /dev/null || ! command -v git &> /dev/null || ! command -v curl &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y ansible git curl
    else
      echo "Ansible, Git, and Curl are already installed."
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Ensure Homebrew is installed
    if ! command -v brew &> /dev/null; then
      echo "Homebrew not found. Installing Homebrew..."
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
  echo "Cloning or updating the repository..."

  if [[ ! -d "$REPO_NAME" ]]; then
    git clone "$REPO_URL"
  else
    cd "$REPO_NAME"
    git pull --rebase
    cd ..
  fi
}

# Run the Ansible playbook
run_playbook() {
  echo "Running the Ansible playbook..."

  cd "$REPO_NAME"
  ansible-playbook playbook.yml --tags "$SETUP_TAG"
}

# Clean up the repository folder
cleanup() {
  echo "Cleaning up..."
  cd ..
  rm -rf "$REPO_NAME"
}

# Main function
main() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
  fi

  install_dependencies
  clone_repository
  run_playbook
  cleanup
  echo "Setup completed successfully!"
}

# Run the script
main "$@"
