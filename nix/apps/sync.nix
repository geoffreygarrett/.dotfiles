{ pkgs, ... }:

pkgs.writeShellScriptBin "sync" ''
        set -euo pipefail

        # Ensure dependencies are available
        export PATH="${pkgs.ssh-to-age}/bin:${pkgs.toml2json}/bin:${pkgs.jq}/bin:${pkgs.gawk}/bin:${pkgs.coreutils}/bin"

        # Convert the TOML file to JSON format
        configJson=$(${pkgs.toml2json}/bin/toml2json < ".nixus.toml")

        # Use jq to parse the JSON content
        authorized_keys=($(${pkgs.jq}/bin/jq -r '.authorized_keys[]' <<< "$configJson"))
        mariner_nodes=($(${pkgs.jq}/bin/jq -r '.mariner_nodes[]' <<< "$configJson"))

        # Combine the SSH keys
        ssh_keys=("''${authorized_keys[@]}" "''${mariner_nodes[@]}")

        # Function to extract the comment from an SSH key
        get_comment() {
          local key="$1"
          echo "$key" | ${pkgs.gawk}/bin/awk '{print $3}'
        }

        # Initialize variables
        age_keys_yaml=""
        age_key_references=""

        # Generate age keys with YAML anchors
        for key in "''${ssh_keys[@]}"; do
          comment=$(get_comment "$key")
          age_key=$(echo "$key" | ${pkgs.ssh-to-age}/bin/ssh-to-age)
          # Append to age_keys_yaml with YAML anchor
          age_keys_yaml+=$'\n'"- &$comment $age_key"
          # Append to age_key_references with YAML reference
          age_key_references+=$'\n'"              - *$comment"
        done

        # Build the final .sops.yaml content
        sops_yaml_content="keys:''${age_keys_yaml}

  creation_rules:
    - path_regex: secrets/default.yaml
      key_groups:
        - age:''${age_key_references}
  "

        # Write the .sops.yaml file
        echo "$sops_yaml_content" > .sops.yaml
''
