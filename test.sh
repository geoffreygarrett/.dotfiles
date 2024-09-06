#!/bin/bash

# Set the version
VERSION="1.72.2"

# Set the URL
URL="https://pkgs.tailscale.com/stable/Tailscale-${VERSION}-macos.zip"

# Set the output file name
OUTPUT_FILE="Tailscale-${VERSION}-macos.zip"

# Download the file
echo "Downloading Tailscale version ${VERSION}..."
curl -L -o "$OUTPUT_FILE" "$URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Download failed. Please check the URL and try again."
    exit 1
fi

# Calculate the SHA256 hash
echo "Calculating SHA256 hash..."
HASH=$(shasum -a 256 "$OUTPUT_FILE" | awk '{print $1}')

echo "Download complete. SHA256 hash: $HASH"

# Print the line to add to the Nix package definition
echo "Add this line to your Nix package definition:"
echo "sha256 = \"$HASH\";"

# Clean up
echo "Cleaning up..."
rm "$OUTPUT_FILE"

echo "Script completed."