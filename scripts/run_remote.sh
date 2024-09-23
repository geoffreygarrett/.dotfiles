#!/bin/sh

# Step 1: Define a temporary directory for certificate storage
CERT_DIR="/tmp/curl-certs"
CERT_FILE="$CERT_DIR/ca-certificates.crt"

# Step 2: Create the certificate directory if it doesn't exist
mkdir -p $CERT_DIR

# Step 3: Download the CA certificates from a trusted source
echo "Downloading CA certificates bundle..."
curl --insecure -o $CERT_FILE https://curl.se/ca/cacert.pem

if [ $? -ne 0 ]; then
    echo "Error: Failed to download CA certificates"
    exit 1
fi

echo "CA certificates downloaded successfully."

# Step 4: Download and execute the injected script
echo "Downloading and running the Nix installer script..."

curl --proto '=https' --tlsv1.2 --cacert $CERT_FILE -sSf https://your-server.com/install_nix.sh -o /tmp/install_nix.sh

if [ $? -ne 0 ]; then
    echo "Error: Failed to download Nix installer script"
    exit 1
fi

# Make the script executable
chmod +x /tmp/install_nix.sh

# Run the injected script
sh /tmp/install_nix.sh

if [ $? -ne 0 ]; then
    echo "Error: Failed to execute the Nix installer script"
    exit 1
fi

# Clean up certificates
rm -rf $CERT_DIR

echo "Nix installation complete!"
