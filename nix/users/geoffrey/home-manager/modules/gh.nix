{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  gh-wrapped =
    if
      pkgs.lib.hasAttrByPath [
        "sops"
        "secrets"
        "github-token"
        "path"
      ] config
    then
      pkgs.writeShellScriptBin "gh" ''
        GITHUB_TOKEN=$(cat ${config.sops.secrets.github-token.path})
        export GITHUB_TOKEN
        ${pkgs.gh}/bin/gh "$@"
      ''
    else
      pkgs.gh;
in
{
  programs.gh = {
    enable = true;
    package = gh-wrapped;
    settings = {
      options = {
        git_protocol = "ssh";
        editor = "nvim";
        prompt = "enabled";
        prefer_editor_prompt = "enabled";
        pager = "less";
        aliases = {
          pr = "pull-request";
          ci = "run checks";
          co = "checkout";
          st = "status";
          br = "branch";
          lg = "log";
          cm = "commit";
          pu = "push";
          pl = "pull";
          me = "merge";
          re = "rebase";
          df = "diff";
          cp = "cherry-pick";
          rb = "rebase";
          cl = "clone";
        };
        # http_unix_socket = "/run/user/1000/sops/gh.sock";
        # browser = "firefox";
      };
    };
  };
}
