#!/bin/sh

# Function to play a sound on macOS
play_sound_mac() {
    if command -v afplay >/dev/null 2>&1; then
        afplay /System/Library/Sounds/Bottle.aiff
    else
        echo "afplay command not found, unable to play sound."
    fi
}

# Function to beep or play a sound on Linux
play_sound_linux() {
    if command -v paplay >/dev/null 2>&1; then
        paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga
    elif command -v beep >/dev/null 2>&1; then
        beep
    else
        echo -e "\a"
    fi
}

# Function to play a sound on Android (Termux or Terminus)
play_sound_android() {
    if command -v termux-vibrate >/dev/null 2>&1; then
        termux-vibrate
    elif command -v termux-notification >/dev/null 2>&1; then
        termux-notification --sound --title "Beep" --content "Beep sound"
    else
        echo "Unable to play sound on Android. Please install termux-vibrate or termux-notification."
    fi
}

# Detect OS and call appropriate function
case "$(uname -s)" in
    Darwin)
        # macOS
        play_sound_mac
        ;;
    Linux)
        # Linux
        play_sound_linux
        ;;
    Android)
        # Android (Termux or Terminus)
        play_sound_android
        ;;
    *)
        echo "Unsupported operating system."
        ;;
esac
