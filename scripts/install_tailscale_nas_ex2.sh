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

# Tailscale version and architecture
TAILSCALE_VERSION="1.72.1"
TAILSCALE_ARCH="arm" # Change to "arm64" if your NAS supports it

# Derived variables
TAILSCALE_FILE="tailscale_${TAILSCALE_VERSION}_${TAILSCALE_ARCH}.tgz"
TAILSCALE_URL="https://pkgs.tailscale.com/stable/${TAILSCALE_FILE}"
TAILSCALE_DIR="tailscale_${TAILSCALE_VERSION}_${TAILSCALE_ARCH}"

# Step 1: Change to persistent storage path
cd /mnt/HD/HD_a2 || {
  print_color "$RED" "Failed to change directory to /mnt/HD/HD_a2"
  exit 1
}
print_color "$GREEN" "Changed to persistent storage path"

# Step 2: Download Tailscale
print_color "$YELLOW" "Downloading Tailscale version ${TAILSCALE_VERSION} for ${TAILSCALE_ARCH}..."
wget --no-check-certificate "$TAILSCALE_URL" || {
  print_color "$RED" "Failed to download Tailscale"
  exit 1
}
print_color "$GREEN" "Tailscale downloaded successfully"

# Step 3: Extract Tailscale
print_color "$YELLOW" "Extracting Tailscale..."
tar zxf "$TAILSCALE_FILE" || {
  print_color "$RED" "Failed to extract Tailscale"
  exit 1
}
print_color "$GREEN" "Tailscale extracted successfully"

# Step 4: Set up Tailscale
cd "$TAILSCALE_DIR" || {
  print_color "$RED" "Failed to change directory to $TAILSCALE_DIR"
  exit 1
}
mkdir -p tailscale_lib || {
  print_color "$RED" "Failed to create tailscale_lib directory"
  exit 1
}
ln -sf "/mnt/HD/HD_a2/$TAILSCALE_DIR/tailscale_lib" /var/lib/tailscale || {
  print_color "$RED" "Failed to create symbolic link"
  exit 1
}
print_color "$GREEN" "Tailscale set up successfully"

# Step 5: Start Tailscale daemon
print_color "$YELLOW" "Starting Tailscale daemon..."
./tailscaled &
sleep 5 # Give tailscaled some time to start

# Step 6: Get Tailscale login link
print_color "$YELLOW" "Getting Tailscale login link..."
LOGIN_CMD="./tailscale up --qr --accept-dns=false --netfilter-mode=off --snat-subnet-routes=false"
print_color "$GREEN" "Tailscale login command: $LOGIN_CMD"
print_color "$YELLOW" "Please run the above command in the current directory to log in and attach the NAS to your account."

# Step 7: Modify startup script
print_color "$YELLOW" "Modifying startup script..."
STARTUP_SCRIPT="/mnt/HD/HD_a2/Nas_Prog/plexmediaserver/start.sh"
if [ ! -f "$STARTUP_SCRIPT" ]; then
  print_color "$RED" "Startup script not found. Please modify the STARTUP_SCRIPT variable in this script."
  exit 1
fi

# Check if Tailscale entries already exist in the startup script
if grep -q "Tailscale startup" "$STARTUP_SCRIPT"; then
  print_color "$YELLOW" "Tailscale entries already exist in startup script. Updating..."
  sed -i '/# Tailscale startup/,/tailscale up/d' "$STARTUP_SCRIPT"
fi

# Add new Tailscale startup entries
cat <<EOT >>"$STARTUP_SCRIPT"

# Tailscale startup
ln -sf /mnt/HD/HD_a2/$TAILSCALE_DIR/tailscale_lib /var/lib/tailscale
cd /mnt/HD/HD_a2/$TAILSCALE_DIR
./tailscaled &
sleep 5
./tailscale up --accept-dns=false --netfilter-mode=off --snat-subnet-routes=false
EOT
print_color "$GREEN" "Startup script modified successfully"

print_color "$GREEN" "Tailscale installation completed successfully"
print_color "$YELLOW" "Please reboot your NAS to complete the setup"
print_color "$YELLOW" "After reboot, you can check Tailscale status by running: /mnt/HD/HD_a2/$TAILSCALE_DIR/tailscale status"