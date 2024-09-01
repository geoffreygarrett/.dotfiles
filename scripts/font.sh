#!/bin/bash

# Define the font download URL
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"

# Create the font directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Download the font
echo "Downloading JetBrains Mono Nerd Font..."
curl -L -o "$FONT_DIR/JetBrainsMono.zip" "$FONT_URL"

# Extract the font
echo "Extracting fonts..."
unzip -o "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"

# Clean up the zip file
rm "$FONT_DIR/JetBrainsMono.zip"

# Update font cache (Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Updating font cache..."
    fc-cache -fv
fi

# Install on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing fonts on macOS..."
    cp -R "$FONT_DIR/"* /Library/Fonts/
fi

# Install on Windows (using PowerShell)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "Installing fonts on Windows..."
    powershell -command "Expand-Archive -Path '$FONT_DIR/JetBrainsMono.zip' -DestinationPath '$FONT_DIR'; Remove-Item '$FONT_DIR/JetBrainsMono.zip';"
    powershell -command "Get-ChildItem '$FONT_DIR' -Recurse | ForEach-Object { Copy-Item -Path $_.FullName -Destination 'C:\Windows\Fonts' }"
fi

echo "JetBrains Mono Nerd Font installation completed!"
