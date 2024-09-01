{...}: {
  programs.git = {
    enable = true;
    userName = "Geoffrey Garrett";
    userEmail = "26066340+geoffreygarrett@users.noreply.github.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };
    extraConfig = {
      init.defaultBranch = "main";
      color = {
        ui = "auto";
      };
      push = {
        default = "simple";
      };
    };
  };
}

