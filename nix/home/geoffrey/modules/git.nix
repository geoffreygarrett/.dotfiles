{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "geoffreygarrett";
    userEmail = "26066340+geoffreygarrett@users.noreply.github.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
    };
    extraConfig = {
      init.defaultBranch = "main";
      color = { ui = "auto"; };
      push = { default = "simple"; };
      fetch = { prune = true; };
      pull = { rebase = true; };
    };
  };
}
