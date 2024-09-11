{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.zellij = {
    enable = true;
    settings.configFile = "${inputs.self}/dotfiles/zellij/config.kdl";
  };
}
