#!/usr/bin/env bash

sops-ssh() {
 local age_public_key
 local age_private_key
 age_public_key=$(ssh-to-age -i ~/.ssh/id_ed25519.pub 2>/dev/null)
 if [ $? -ne 0 ]; then
 echo "Error generating age public key from SSH key" >&2
 return 1
 fi
 age_private_key=$(ssh-to-age -private-key -i ~/.ssh/id_ed25519 2>/dev/null)
 if [ $? -ne 0 ]; then
 echo "Error generating age private key from SSH key" >&2
 return 1
 fi
 if [ $# -eq 0 ]; then
 echo "Usage: sops_ssh [sops_options] <file>"
 return 1
 fi
 SOPS_AGE_KEY="$age_private_key" sops --age "$age_public_key" "$@"
}


# If the script is sourced, define the function. If run directly, execute the function.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f sops-ssh
else
    sops-ssh "$@"
fi
