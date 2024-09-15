final: prev: {
  key-fetcher = final.lib.makeOverridable (
    {
      config ? final.config,
    }:
    if
      final.lib.hasAttrByPath [
        "sops"
        "secrets"
      ] config
    then
      final.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        fetch_key() {
          if [ -f "$1" ]; then
            cat "$1"
          else
            echo "Error: $2 not found."
            exit 1
          fi
        }
        case "$1" in
          "github-token")
            fetch_key "${config.sops.secrets.github-token.path}" "GitHub token"
            ;;
          "openai-api-key")
            fetch_key "${config.sops.secrets.openai-api-key.path}" "OpenAI API key"
            ;;
          *)
            echo "Usage: $0 {github-token|openai-api-key}"
            exit 1
            ;;
        esac
      ''
    else
      final.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        echo "Error: sops secrets are not configured."
        exit 1
      ''
  ) { };
}
