{
  inputs,
  pkgs,
  ...
}:

let
  username = "geoffrey";
in
{
  imports = [
    ./modules/gh.nix
    ./modules/git.nix
    ./modules/tms.nix
    ./modules/starship.nix
    ./modules/nushell.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/htop.nix
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
