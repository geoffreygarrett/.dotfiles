{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "geoffrey";
in
{
  imports = [
    ./modules/ssh.nix
    ./modules/zsh.nix
    ./modules/git.nix
    # Add other module imports here as needed
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Pass necessary variables to imported modules
  _module.args = {
    inherit username;
  };
}
