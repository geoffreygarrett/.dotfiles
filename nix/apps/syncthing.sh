#!/bin/bash

# Set variables
KEY_FILE="syncthing_key.pem"
CERT_FILE="syncthing_cert.pem"
DAYS_VALID=3650 # Certificate validity in days (10 years)
KEY_SIZE=3072   # RSA key size

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if OpenSSL is installed
if ! command_exists openssl; then
  echo "Error: OpenSSL is not installed. Please install OpenSSL and try again."
  exit 1
fi

# Generate private key
echo "Generating private key..."
openssl genrsa -out "$KEY_FILE" $KEY_SIZE

# Generate self-signed certificate
echo "Generating self-signed certificate..."
openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days $DAYS_VALID -subj "/CN=syncthing"

# Set appropriate permissions
chmod 400 "$KEY_FILE"
chmod 444 "$CERT_FILE"

echo "Key and certificate generation complete."
echo "Private key: $KEY_FILE"
echo "Certificate: $CERT_FILE"
echo ""
echo "You can now use these in your Syncthing configuration:"
echo "services = {"
echo "  syncthing = {"
echo "    key = \"\${</path/to/$KEY_FILE>}\";"
echo "    cert = \"\${</path/to/$CERT_FILE>}\";"
echo "    ..."
echo "  };"
echo "};"
