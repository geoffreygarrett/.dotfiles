final: prev:

let
  sops-wrapped = prev.writeShellScriptBin "sops" ''
    set -euo pipefail

    sops_ssh() {
      local age_public_key
      local age_private_key

      age_public_key=$(${prev.ssh-to-age}/bin/ssh-to-age -i ~/.ssh/id_ed25519.pub 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "Error generating age public key from SSH key" >&2
        return 1
      fi

      age_private_key=$(${prev.ssh-to-age}/bin/ssh-to-age -private-key -i ~/.ssh/id_ed25519 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "Error generating age private key from SSH key" >&2
        return 1
      fi

      if [ $# -eq 0 ]; then
        echo "Usage: sops [sops_options] <file>" >&2
        return 1
      fi

      SOPS_AGE_KEY="$age_private_key" ${prev.sops}/bin/sops --age "$age_public_key" "$@"
    }

    sops_ssh "$@"
  '';

in
{
  sops = sops-wrapped;
}
