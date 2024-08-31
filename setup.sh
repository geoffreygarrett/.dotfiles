#!/bin/bash

set -euo pipefail

GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="${REPO_NAME:-cross-platform-terminal-setup}"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
SETUP_TAG="${SETUP_TAG:-setup}"

usage() {
  echo "Usage: bash <(curl -sL https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/main/setup.sh)"
  echo "You can override the default GitHub username and repository name by setting the GITHUB_USERNAME and REPO_NAME environment variables."
}

install_dependencies() {
  echo "Installing dependencies..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible git curl
  elif [[ "$OSTYPE" == "darwin"* ]]; then
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

clone_repository() {
  echo "Cloning or updating the repository..."

  if [[ ! -d "$REPO_NAME" ]]; then
    git clone "$REPO_URL"
  else
    (cd "$REPO_NAME" && git pull --rebase)
  fi
}

run_playbook() {
  echo "Running the Ansible playbook..."

  cd "$REPO_NAME"
  if [[ ! -f "playbook.yml" ]]; then
    echo "Error: playbook.yml not found in the repository."
    exit 1
  fi
  ansible-playbook playbook.yml --tags "$SETUP_TAG"
}

cleanup() {
  echo "Cleaning up..."
  cd ..
  rm -rf "$REPO_NAME"
}

main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
  fi

  install_dependencies
  clone_repository
  run_playbook
  cleanup
  echo "Setup completed successfully!"
}

main "$@"