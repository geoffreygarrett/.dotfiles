{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  gh-wrapped = pkgs.writeShellScriptBin "gh" ''
    GITHUB_TOKEN=$(cat ${config.sops.secrets.github-token.path})
    export GITHUB_TOKEN
    ${pkgs.gh}/bin/gh "$@"
  '';
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
  # Service to login once sops-nix is ready.
  systemd.user.services.gh-auth = {
    Unit = {
      Description = "Authenticate GitHub CLI with token";
      After = [ "sops-nix.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${gh-wrapped}/bin/gh auth login --with-token < ${config.sops.secrets.github-token.path}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
