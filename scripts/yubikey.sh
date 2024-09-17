#!/bin/bash

echo "Welcome to the YubiKey Setup Script for GPG and SSH"
echo "This script will guide you through the process of setting up your YubiKey."
echo "Please ensure your YubiKey is inserted before proceeding."
echo

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required software
echo "Checking for required software..."
for cmd in gpg gpg-agent ssh-agent scdaemon; do
  if ! command_exists $cmd; then
    echo "Error: $cmd is not installed. Please install it and run this script again."
    exit 1
  fi
done
echo "All required software is installed."
echo

# GPG key generation
echo "Let's start by generating a new GPG key pair."
read -p "Enter your full name: " full_name
read -p "Enter your email address: " email

echo "Generating GPG key pair..."
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: $full_name
Name-Email: $email
Expire-Date: 0
%commit
EOF

echo "GPG key pair generated successfully."
echo

# List GPG keys and get the key ID
echo "Here are your GPG keys:"
gpg --list-keys

read -p "Enter the ID of the key you just generated (last 8 characters): " key_id

# Configure GPG to use YubiKey
echo "Configuring GPG to use YubiKey..."
gpg --edit-key $key_id

echo "In the GPG prompt, type these commands:"
echo "  keytocard"
echo "  save"
echo
echo "After executing these commands, your GPG key will be moved to the YubiKey."
echo "Press Enter when you've completed this step."
read

# Configure SSH to use GPG key
echo "Now, let's configure SSH to use the GPG key on your YubiKey."
echo "Add the following to your ~/.gnupg/gpg-agent.conf file:"
echo
echo "enable-ssh-support"
echo "write-env-file ~/.gpg-agent-info"
echo
echo "Then, add this to your ~/.bashrc or ~/.bash_profile:"
echo
echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)'
echo
echo "Finally, restart the GPG agent:"
echo
echo "gpg-connect-agent reloadagent /bye"
echo
echo "Press Enter when you've completed these steps."
read

# Verify setup
echo "Setup complete! Let's verify everything is working correctly."
echo
echo "Testing GPG..."
echo "test" | gpg --clearsign

echo
echo "Testing SSH..."
ssh-add -L

echo
echo "If you see your GPG key above and an SSH key starting with 'ssh-rsa', your YubiKey is set up correctly!"
echo "Remember to back up your GPG key securely before fully committing to using the YubiKey."
echo
echo "Setup complete. Enjoy your enhanced security with YubiKey!"