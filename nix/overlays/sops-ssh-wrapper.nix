final: prev:
let
  sops-wrapped = prev.writeShellScriptBin "sops" ''
    set -euo pipefail
    sops_ssh() {
      local user_age_public_key
      local user_age_private_key
      local host_age_public_key
      local host_age_private_key
      local age_recipients
      local combined_private_keys

      # Generate age keys from user's SSH key
      user_age_public_key=$(${prev.ssh-to-age}/bin/ssh-to-age -i ~/.ssh/id_ed25519.pub 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "Error generating age public key from user's SSH key" >&2
        return 1
      fi
      user_age_private_key=$(${prev.ssh-to-age}/bin/ssh-to-age -private-key -i ~/.ssh/id_ed25519 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "Error generating age private key from user's SSH key" >&2
        return 1
      fi

      # Generate age keys from host's SSH key
      if [ -r "/etc/ssh/ssh_host_ed25519_key.pub" ] && [ -r "/etc/ssh/ssh_host_ed25519_key" ]; then
        host_age_public_key=$(${prev.ssh-to-age}/bin/ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null)
        if [ $? -eq 0 ]; then
          host_age_private_key=$(${prev.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key 2>/dev/null)
          if [ $? -eq 0 ]; then
            age_recipients="$user_age_public_key,$host_age_public_key"
            combined_private_keys=$(printf "%s\n%s" "$user_age_private_key" "$host_age_private_key")
          else
            echo "Warning: Could not generate age private key from host's SSH key" >&2
            age_recipients="$user_age_public_key"
            combined_private_keys="$user_age_private_key"
          fi
        else
          echo "Warning: Could not generate age public key from host's SSH key" >&2
          age_recipients="$user_age_public_key"
          combined_private_keys="$user_age_private_key"
        fi
      else
        echo "Warning: Host SSH key not readable, using only user's key" >&2
        age_recipients="$user_age_public_key"
        combined_private_keys="$user_age_private_key"
      fi

      if [ $# -eq 0 ]; then
        echo "Usage: sops [sops_options] <file>" >&2
        return 1
      fi
      echo "Using age recipients: $age_recipients" >&2
      echo "Using combined_private_keys: $combined_private_keys" >&2
      SOPS_AGE_KEY="$combined_private_keys" ${prev.sops}/bin/sops --age "$age_recipients" "$@"
    }
    sops_ssh "$@"
  '';
in
{
  sops = sops-wrapped;
}
