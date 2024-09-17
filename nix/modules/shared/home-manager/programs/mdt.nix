{ config, pkgs, ... }:

{
  # Enable Home Manager
  programs.home-manager.enable = true;

  # Enable mdt
  programs.mdt = {
    enable = true;
    package = pkgs.mdt; # Assuming mdt is available in nixpkgs
  };

  # Set up environment variables for mdt
  home.sessionVariables = {
    MDT_DIR = "~/tasks";
    MDT_INBOX = "~/tasks/inbox.md";
    MDT_MAIN_COLOR = "#5FAFFF";
    MDT_EDITOR = "nvim -c \"set nonumber\"";
  };

  # Optional: Create an alias for mdt with some default options
  programs.bash.shellAliases = {
    mdtt = "mdt --dir ~/tasks --inbox ~/tasks/inbox.md";
  };

  # Ensure mdt is installed
  home.packages = [ pkgs.mdt ];
}
