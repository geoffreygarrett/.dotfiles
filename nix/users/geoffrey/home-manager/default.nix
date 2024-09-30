{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.username = "geoffrey";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/geoffrey" else "/home/geoffrey";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Basic shell configuration
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Geoffrey Garrett";
    userEmail = "geoffrey@example.com";
  };

  # SSH key configuration
  home.file.".ssh/authorized_keys".text = ''
    ssh-dss AAAAB3Nza... alice@foobar
  '';
}
