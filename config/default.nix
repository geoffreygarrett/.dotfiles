{ pkgs, lib, ... }:

let
  readConfigStructure = dir: builtins.listToAttrs (
    map
      (file: {
        name = lib.removePrefix (toString dir + "/") file;
        content = builtins.readFile file;
      })
      (pkgs.lib.filesystem.listFilesRecursive dir)
  );

  configs = {
    nvim = readConfigStructure ./nvim;
    zsh = readConfigStructure ./zsh;
    alacritty = readConfigStructure ./alacritty;
    zellij = readConfigStructure ./zellij;
    nushell = readConfigStructure ./nushell;
    obsidian = readConfigStructure ./obsidian;
  };

  debugConfig = pkgs.lib.trace "Configs: ${builtins.toJSON configs}" configs;

in
{
  config = debugConfig;
}
