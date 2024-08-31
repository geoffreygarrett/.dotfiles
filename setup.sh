#!/bin/bash

# Source the utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$SCRIPT_DIR/scripts/utils.sh" ]]; then
  echo "Error: utils.sh not found in $SCRIPT_DIR/scripts"
  exit 1
fi
source "$SCRIPT_DIR/scripts/utils.sh"

set -euo pipefail

GITHUB_USERNAME="${GITHUB_USERNAME:-geoffreygarrett}"
REPO_NAME="${REPO_NAME:-cross-platform-terminal-setup}"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
SETUP_TAG="${SETUP_TAG:-setup}"
USE_LOCAL_REPO=false

usage() {
  log "INFO" "Usage: bash <(curl -sL https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/main/setup.sh) [--local]"
  log "INFO" "You can override the default GitHub username and repository name by setting the GITHUB_USERNAME and REPO_NAME environment variables."
  log "INFO" "Use the --local flag to use the local repository instead of cloning from GitHub."
}

install_dependencies() {
  local os=$(detect_os)

  case "$os" in
    "linux")
      run_with_spinner "sudo apt-get update && sudo apt-get install -y software-properties-common"
      run_with_spinner "sudo add-apt-repository --yes --update ppa:ansible/ansible"
      run_with_spinner "sudo apt-get install -y ansible git curl"
      ;;
    "macos")
      if ! command -v brew &> /dev/null; then
        log "INFO" "Homebrew not found. Installing Homebrew..."
        run_with_spinner "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      fi
      run_with_spinner "brew install ansible git curl"
      ;;
    *)
      error "Unsupported OS: $OSTYPE"
      ;;
  esac
}

clone_repository() {
  if [ "$USE_LOCAL_REPO" = true ]; then
    log "INFO" "Using local repository..."
  else
    if [[ ! -d "$REPO_NAME" ]]; then
      run_with_spinner "git clone \"$REPO_URL\""
    else
      (cd "$REPO_NAME" && run_with_spinner "git pull --rebase")
    fi
  fi
}

run_playbook() {
  log "INFO" "Running the Ansible playbook..."

  if [ "$USE_LOCAL_REPO" = true ]; then
    # If using local repo, we assume the playbook is in the current directory
    if [[ ! -f "$SCRIPT_DIR/playbook.yml" ]]; then
      error "Error: playbook.yml not found in the current directory."
    fi
    ansible-playbook -i "localhost," "$SCRIPT_DIR/playbook.yml" --tags "$SETUP_TAG"
  else
    cd "$REPO_NAME"
    if [[ ! -f "playbook.yml" ]]; then
      error "Error: playbook.yml not found in the repository."
    fi
    ansible-playbook -i "localhost," playbook.yml --tags "$SETUP_TAG"
  fi
}

cleanup() {
  if [ "$USE_LOCAL_REPO" = false ]; then
    log "INFO" "Cleaning up..."
    cd ..
    rm -rf "$REPO_NAME"
  fi
}

main() {
  log "INFO" "Starting setup process..."

  local steps=(
    "Install dependencies:install_dependencies"
    "Clone or update repository:clone_repository"
    "Run Ansible playbook:run_playbook"
    "Cleanup:cleanup"
  )

  for step in "${steps[@]}"; do
    IFS=":" read -r step_name step_function <<< "$step"
    if ! execute_step "$step_name" "$step_function"; then
      log "ERROR" "Setup process failed at step: $step_name"
      exit 1
    fi
  done

  log "SUCCESS" "Setup completed successfully!"
}

# Parse the command-line arguments
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--local" ]]; then
  USE_LOCAL_REPO=true
fi

main "$@"
