final: prev: {
  gh = final.lib.makeOverridable (
    {
      gh ? prev.gh,
    }:
    if
      final.lib.hasAttrByPath [
        "sops"
        "secrets"
        "github-token"
        "path"
      ] final.config
    then
      final.writeShellScriptBin "gh" ''
        GITHUB_TOKEN=$(cat ${final.config.sops.secrets.github-token.path})
        export GITHUB_TOKEN
        ${gh}/bin/gh "$@"
      ''
    else
      gh
  ) { };
}
