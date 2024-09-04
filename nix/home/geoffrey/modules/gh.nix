{ config, pkgs, lib, inputs, ... }:

let
  # Wrapper for gh that includes the GitHub token
  gh-wrapped = pkgs.writeShellScriptBin "gh" ''
    export GITHUB_TOKEN=$(cat ${config.sops.secrets.github_token.path})
    ${pkgs.gh}/bin/gh "$@"
  '';
in
{
  sops.secrets.github_token = {
    sopsFile = config.sops.defaultSopsFile;
  };

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
        #       http_unix_socket = "/run/user/1000/sops/gh.sock";
        #       browser = "firefox";
      };
    };
  };

  # Optional: Add a service to ensure GitHub CLI is authenticated
  systemd.user.services.gh-auth = {
    Unit = {
      Description = "Authenticate GitHub CLI with token";
      After = [ "sops-nix.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${gh-wrapped}/bin/gh auth status";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
