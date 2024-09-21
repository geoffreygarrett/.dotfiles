{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.zellij = {
    enable = false;
    settings.configFile = "${inputs.self}/dotfiles/zellij/config.kdl";
  };
}
