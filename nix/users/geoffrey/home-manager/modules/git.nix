{ ... }:
{
  programs.git = {
    enable = true;
    userName = "geoffreygarrett";
    userEmail = "26066340+geoffreygarrett@users.noreply.github.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
      st = "status -sb";
      co = "checkout";
      cob = "checkout -b";
      br = "branch";
      ci = "commit";
      cm = "commit -m";
      amend = "commit --amend --no-edit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      use-ssh = "!f() { git remote set-url origin $(git remote get-url origin | sed -E 's#^https?://([^/]+)/(.+)$#git@\\1:\\2#'); }; f";
      use-https = "!f() { git remote set-url origin $(git remote get-url origin | sed -E 's#^git@([^:]+):(.+)$#https://\\1/\\2#'); }; f";
    };
    extraConfig = {
      init.defaultBranch = "main";
      color.ui = "auto";
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      fetch.prune = true;
      pull.rebase = true;
      core = {
        editor = "vim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      diff = {
        colorMoved = "zebra";
      };
      merge = {
        conflictStyle = "diff3";
      };
      rebase = {
        autoStash = true;
      };
    };
    ignores = [
      ".DS_Store"
      "*.swp"
      ".vscode"
      "*.log"
      "node_modules"
      "build"
      "dist"
    ];
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
    lfs.enable = true;
  };
}
