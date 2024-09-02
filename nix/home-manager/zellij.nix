{ config, pkgs, ... }:
{
  programs.zellij = {
    enable = true;
#    settings = {
#      configFile = config.zellij.content."config.kdl";
#    };
  };
}
