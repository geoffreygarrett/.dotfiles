final: prev: {
  key-fetcher = final.lib.makeOverridable (
    {
      config ? final.config,
    }:
    let
      secretNames = final.lib.attrNames (config.sops.secrets or { });
      secretCases = final.lib.concatMapStrings (name: ''
        "${name}")
          fetch_key "${
            final.lib.getAttrFromPath [
              "sops"
              "secrets"
              name
              "path"
            ] config
          }" "${name}"
          ;;
      '') secretNames;
    in
    if
      final.lib.hasAttrByPath [
        "sops"
        "secrets"
      ] config
    then
      final.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        fetch_key() {
          if [ -z "$1" ]; then
            echo "Error: Secret path for $2 is not defined." >&2
            exit 1
          elif [ -f "$1" ]; then
            cat "$1"
          else
            echo "Error: $2 not found at $1." >&2
            exit 1
          fi
        }
        case "$1" in
          ${secretCases}
          *)
            echo "Usage: $0 {${final.lib.concatStringsSep "|" secretNames}}" >&2
            exit 1
            ;;
        esac
      ''
    else
      final.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        echo "Error: sops secrets are not configured." >&2
        exit 1
      ''
  ) { };
}
