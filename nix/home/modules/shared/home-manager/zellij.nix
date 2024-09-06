{ config, pkgs, inputs, ... }: {
  programs.zellij = {
    settings.configFile = "${inputs.self}/dotfiles/zellij/config.kdl";
  };
}
