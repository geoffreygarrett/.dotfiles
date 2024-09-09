#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to prompt for SSH credentials
prompt_credentials() {
    print_color "$BLUE" "Please enter your NAS credentials:"
    read -p "Enter NAS username: " NAS_USER
    read -p "Enter NAS hostname or IP address: " NAS_HOST
    read -p "Enter NAS SSH port (default 22): " NAS_PORT
    NAS_PORT=${NAS_PORT:-22}
    read -s -p "Enter NAS password: " NAS_PASSWORD
    echo ""

    print_color "$YELLOW" "Debug: Credentials entered:"
    print_color "$YELLOW" "Username: $NAS_USER"
    print_color "$YELLOW" "Hostname: $NAS_HOST"
    print_color "$YELLOW" "Port: $NAS_PORT"
}

# Function to check SSH connection
check_ssh_connection() {
    print_color "$YELLOW" "Checking SSH connection..."
    if ! sshpass -p "$NAS_PASSWORD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$NAS_USER@$NAS_HOST" -p "$NAS_PORT" 'echo "SSH connection successful"'; then
        print_color "$RED" "Error: Unable to connect to NAS. Please check your credentials and try again."
        exit 1
    fi
}

# Function to execute remote command with error handling
execute_remote_command() {
    local command="$1"
    local error_message="$2"
    if ! sshpass -p "$NAS_PASSWORD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$NAS_USER@$NAS_HOST" -p "$NAS_PORT" "$command"; then
        print_color "$RED" "Error: $error_message"
        exit 1
    fi
}

# Upload and execute the remote script on the NAS
run_remote_script() {
    print_color "$YELLOW" "Creating temporary directory on the NAS..."
    execute_remote_command "mkdir -p /tmp/nix_install" "Failed to create temporary directory on NAS."

    print_color "$YELLOW" "Uploading the installation script to the NAS..."
    cat <<'EOF' > /tmp/install_nix_remote.sh
#!/bin/sh
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    printf "${color}${message}${NC}\n"
}

# Step 1: Define a temporary directory for certificate storage
CERT_DIR="/tmp/curl-certs"
CERT_FILE="$CERT_DIR/ca-certificates.crt"

# Step 2: Create the certificate directory if it doesn't exist
mkdir -p $CERT_DIR

# Step 3: Download the CA certificates
print_color "$YELLOW" "Downloading CA certificates..."
if ! curl --insecure -o $CERT_FILE https://curl.se/ca/cacert.pem; then
    print_color "$RED" "Error: Failed to download CA certificates"
    exit 1
fi
print_color "$GREEN" "CA certificates downloaded successfully."

# Step 4: Install Nix using the downloaded certificates
print_color "$YELLOW" "Installing Nix..."
if ! curl --proto '=https' --tlsv1.2 --cacert $CERT_FILE -sSf https://install.determinate.systems/nix | sh -s -- install --no-confirm; then
    print_color "$RED" "Error: Nix installation failed"
    exit 1
fi

print_color "$GREEN" "Nix installation completed. Verifying installation..."

# Step 5: Verify Nix installation
if ! command -v nix >/dev/null 2>&1; then
    print_color "$RED" "Error: Nix command not found after installation"
    exit 1
fi

print_color "$GREEN" "Nix installed and verified successfully"
rm -rf $CERT_DIR
EOF

    if ! sshpass -p "$NAS_PASSWORD" scp -P "$NAS_PORT" /tmp/install_nix_remote.sh "$NAS_USER@$NAS_HOST:/tmp/nix_install/install_nix_remote.sh"; then
        print_color "$RED" "Error: Failed to upload installation script to NAS."
        exit 1
    fi

    print_color "$YELLOW" "Running the installation script on the NAS..."
    execute_remote_command "sh /tmp/nix_install/install_nix_remote.sh" "Failed to execute Nix installation script on NAS."

    # Clean up
    rm /tmp/install_nix_remote.sh
}

# Main flow
prompt_credentials
check_ssh_connection
run_remote_script

print_color "$GREEN" "Script execution completed. Nix should now be installed on your NAS."
print_color "$YELLOW" "Please verify the installation by logging into your NAS and running 'nix --version'."