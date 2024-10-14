#!/usr/bin/env bash

set -euo pipefail

HOSTNAME="apollo"
OUTPUT_FILE="./secrets/hosts/${HOSTNAME}/syncthing.yaml"

mkdir -p "$(dirname "$OUTPUT_FILE")"

nix-shell -p syncthing sops --run "
    syncthing -generate=/tmp/syncthing-config
    DEVICE_ID=\$(grep -oP 'device id=\"\K[A-Z0-9-]+' /tmp/syncthing-config/config.xml | head -1)
    GUI_PASSWORD=\$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
    
    cat << EOF > /tmp/syncthing_secrets.yaml
syncthing:
    cert: |
\$(sed 's/^/        /' /tmp/syncthing-config/cert.pem)
    key: |
\$(sed 's/^/        /' /tmp/syncthing-config/key.pem)
    gui-password: \"\$GUI_PASSWORD\"
    device-id: \"\$DEVICE_ID\"
EOF

    HOST_KEY=\$(grep \"${HOSTNAME}\" .sops.yaml | awk '{print \$2}')
    sops --encrypt --age \"\$HOST_KEY\" /tmp/syncthing_secrets.yaml > \"$OUTPUT_FILE\"
    rm -rf /tmp/syncthing-config /tmp/syncthing_secrets.yaml
    
    echo \"Syncthing secrets encrypted and saved to $OUTPUT_FILE\"
    echo \"Device ID: \$DEVICE_ID\"
    echo \"GUI Password: \$GUI_PASSWORD\"
"
