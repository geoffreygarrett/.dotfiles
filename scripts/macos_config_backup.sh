#!/bin/bash

# Configuration
ENABLE_VSCODE_BACKUP=true
ENABLE_ITERM2_BACKUP=true
ENABLE_MAIL_BACKUP=false
ENABLE_CHROME_BACKUP=false
ENABLE_PHOTOS_BACKUP=false

# Get the current timestamp in a format like '2024-09-06_14-30-45'
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the backup directory with the timestamp
BACKUP_DIR=~/Backup/macos_config_backup/$TIMESTAMP
mkdir -p "$BACKUP_DIR"

echo "Starting full macOS backup at $TIMESTAMP..."

# Function to backup plist files
backup_plist() {
    local domain="$1"
    local filename="$2"
    echo "Backing up $filename settings..."
    defaults export "$domain" "$BACKUP_DIR/$filename.plist"
    plutil -convert xml1 -o "$BACKUP_DIR/$filename-readable.plist" "$BACKUP_DIR/$filename.plist"
}

# Backup various settings
backup_plist "com.apple.dock" "dock"
backup_plist "com.apple.AppleMultitouchTrackpad" "trackpad"
backup_plist "com.apple.keyboard" "keyboard"
backup_plist "com.apple.finder" "finder"

# Backup Homebrew packages and casks
if command -v brew &> /dev/null; then
    echo "Backing up Homebrew package list..."
    brew list > "$BACKUP_DIR/brew-packages.txt"
    brew list --cask > "$BACKUP_DIR/brew-cask-apps.txt"
else
    echo "Homebrew not found, skipping package backup."
fi

# Backup network and Wi-Fi settings
echo "Backing up network and Wi-Fi settings..."
networksetup -listallhardwareports > "$BACKUP_DIR/network-info.txt"
networksetup -listpreferredwirelessnetworks en0 > "$BACKUP_DIR/wifi-networks.txt"

# Backup various system settings
echo "Backing up system settings..."
pmset -g > "$BACKUP_DIR/energy-saver.txt"
defaults read /Library/Preferences/com.apple.Bluetooth > "$BACKUP_DIR/bluetooth-settings.plist"
defaults read com.apple.controlstrip > "$BACKUP_DIR/touchbar-settings.txt"
system_profiler SPAudioDataType > "$BACKUP_DIR/sound-settings.txt"
system_profiler SPDisplaysDataType > "$BACKUP_DIR/display-settings.txt"
tmutil destinationinfo > "$BACKUP_DIR/timemachine-settings.txt"
defaults read > "$BACKUP_DIR/system-defaults.txt"
system_profiler SPHardwareDataType > "$BACKUP_DIR/hardware-info.txt"

# Backup user configuration files
echo "Backing up user configuration files..."
cp ~/.gitconfig "$BACKUP_DIR/gitconfig_backup" 2>/dev/null || echo "No .gitconfig found"
cp -r ~/.ssh "$BACKUP_DIR/ssh_backup" 2>/dev/null || echo "No .ssh directory found"
cp ~/.zshrc "$BACKUP_DIR/zshrc_backup" 2>/dev/null || echo "No .zshrc found"
cp ~/.bash_profile "$BACKUP_DIR/bash_profile_backup" 2>/dev/null || echo "No .bash_profile found"
cp ~/.bashrc "$BACKUP_DIR/bashrc_backup" 2>/dev/null || echo "No .bashrc found"

# Backup VSCode settings
if [ "$ENABLE_VSCODE_BACKUP" = true ]; then
    echo "Backing up VSCode settings..."
    cp ~/Library/Application\ Support/Code/User/settings.json "$BACKUP_DIR/vscode-settings.json" 2>/dev/null || echo "VSCode settings not found"
    cp ~/Library/Application\ Support/Code/User/keybindings.json "$BACKUP_DIR/vscode-keybindings.json" 2>/dev/null || echo "VSCode keybindings not found"
fi

# Backup iTerm2 settings
if [ "$ENABLE_ITERM2_BACKUP" = true ]; then
    echo "Backing up iTerm2 settings..."
    cp ~/Library/Preferences/com.googlecode.iterm2.plist "$BACKUP_DIR/iterm2-settings.plist" 2>/dev/null || echo "iTerm2 settings not found"
fi

# Backup Apple Mail settings
if [ "$ENABLE_MAIL_BACKUP" = true ]; then
    echo "Backing up Apple Mail settings..."
    cp -r ~/Library/Mail "$BACKUP_DIR/mail_backup" 2>/dev/null || echo "Mail data not found"
fi

# Backup Calendar, Reminders, and Contacts
echo "Backing up Calendar, Reminders, and Contacts data..."
cp -r ~/Library/Calendars "$BACKUP_DIR/calendars_backup" 2>/dev/null || echo "Calendar data not found"
cp -r ~/Library/Application\ Support/AddressBook "$BACKUP_DIR/contacts_backup" 2>/dev/null || echo "Contacts data not found"

# Backup Dock applications
echo "Backing up Dock applications..."
defaults read com.apple.dock persistent-apps > "$BACKUP_DIR/dock-apps.txt"

# Backup Installed Applications
echo "Listing installed applications in /Applications..."
ls /Applications > "$BACKUP_DIR/installed-applications.txt"

# Backup browser settings
if [ "$ENABLE_CHROME_BACKUP" = true ]; then
    echo "Backing up Chrome, Brave, and Firefox browser profiles and settings..."
    cp -r ~/Library/Application\ Support/Google/Chrome "$BACKUP_DIR/chrome-backup" 2>/dev/null || echo "Chrome data not found"
    cp -r ~/Library/Application\ Support/BraveSoftware/Brave-Browser "$BACKUP_DIR/brave-backup" 2>/dev/null || echo "Brave data not found"
    cp -r ~/Library/Application\ Support/Firefox "$BACKUP_DIR/firefox-backup" 2>/dev/null || echo "Firefox data not found"
fi

# Backup Photos library
if [ "$ENABLE_PHOTOS_BACKUP" = true ]; then
    echo "Backing up Photos library..."
    cp -r ~/Pictures/Photos\ Library.photoslibrary "$BACKUP_DIR/photos_backup" 2>/dev/null || echo "Photos library not found"
fi

echo "Backup complete! All backups are saved in $BACKUP_DIR"