{
  self,
  inputs,
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared/cachix
    ../../modules/shared
    ../../modules/darwin
  ];

  services.nix-daemon.enable = true;

  # Environment packages
  environment.systemPackages =
    with pkgs;
    [ ] ++ (import ../../modules/shared/packages { inherit pkgs; });

  #  environment.sessionVariables = {
  #    EDITOR = "nvim";
  #    VISUAL = "nvim";
  #    PAGER = "less";
  #    LESS = "-R";
  #    LESSOPEN = "| $(which lesspipe.sh) %s";
  #    LESSCLOSE = "kill %s";
  #    LESS_TERMCAP_mb = "\e[1;31m";
  #    LESS_TERMCAP_md = "\e[1;31m";
  #    LESS_TERMCAP_me = "\e[0m";
  #    LESS_TERMCAP_se = "\e[0m";
  #    LESS_TERMCAP_so = "\e[1;44;33m";
  #    LESS_TERMCAP_ue = "\e[0m";
  #    LESS_TERMCAP_us = "\e[1;32m";
  #  };

  # Placeholder for host-specific configurations
  # ...

}
