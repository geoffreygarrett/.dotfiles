#!/bin/bash

# Unload and remove all Nix-related launchd services
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null
sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist

# Remove Nix-related files and directories
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf /var/root/.nix-*
sudo rm -rf $HOME/.nix-*
sudo rm -rf $HOME/.nixpkgs
sudo rm -rf $HOME/.config/nixpkgs

# Remove Nix from shell configuration files
sudo sed -i '.bak' '/# Nix/,/# End Nix/d' /etc/zshrc /etc/bashrc /etc/profile
sed -i '.bak' '/# Nix/,/# End Nix/d' $HOME/.zshrc $HOME/.bash_profile $HOME/.profile

# Remove Nix from synthetic.conf
sudo sed -i '.bak' '/^nix$/d' /etc/synthetic.conf

# Remove Nix-related users and groups
sudo dscl . -delete /Users/_nixbuild 2>/dev/null
sudo dscl . -delete /Groups/nixbld 2>/dev/null

# Remove Nix from PATH
sudo sed -i '.bak' '\|/nix/var/nix/profiles/default/bin|d' /etc/paths
sed -i '.bak' 's|:/nix/var/nix/profiles/default/bin||g' $HOME/.bash_profile $HOME/.zshrc

# Remove any Nix-related environment variables
unset NIX_PROFILES NIX_SSL_CERT_FILE NIX_PATH

# Remove the Nix Store volume
sudo diskutil apfs deleteVolume "Nix Store" 2>/dev/null

# Remove nix-darwin specific files
sudo rm -rf /run
sudo rm -rf /etc/static
sudo rm -rf /etc/darwin
sudo rm -f /etc/synthetic.conf

# Remove nix-darwin from nix channels
nix-channel --remove darwin 2>/dev/null

# Rebuild the directory cache
sudo update_dyld_shared_cache -force

echo "Forceful Nix and nix-darwin removal completed. Please restart your computer for changes to take full effect."