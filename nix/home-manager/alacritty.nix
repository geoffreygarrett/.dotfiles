{ config, pkgs, lib, ... }:

let
  # Read the Alacritty configuration from TOML file
  #  alacrittyConfig = builtins.fromTOML (builtins.readFile ../../config/alacritty/alacritty.toml);

  #  # Write the config to a file in the Nix store
  #  configPath = pkgs.writeText "alacritty-config.toml" (builtins.toJSON alacrittyConfig);


  #   pkgs.alacritty.override {
  #    package = pkgs.alacritty;
  #    config = alacrittyConfig;
  #    };
  ##  # Create a wrapper script for Alacritty
  #  alacrittyWrapper = pkgs.writeShellScriptBin "alacritty" ''
  #    ${pkgs.alacritty}/bin/alacritty --config-file ~/.config/alacritty/alacritty.toml "$@"
  #  '';

in
{
  programs.alacritty = {
    enable = true;
  };

  #  home.file."alacritty/alacritty.toml" = {
  #    text = builtins.readFile ../../config/alacritty/alacritty.toml;
  #  };
  #  home.config."alacritty/alacritty.toml" = {
  #    text = builtins.readFile ../../config/alacritty/alacritty.toml;
  #  };

  #  home.file."alacritty/themes" = {
  #    source = ../../config/alacritty/themes;
  #    recursive = true;
  #  };

  #  home.config."alacritty/themes" = {
  #    source = ../../config/alacritty/themes;
  #    recursive = true;
  #  };

  #  # Symlink the original config file to maintain editability
  #  xdg.configFile."alacritty-config.toml".source =
  #    config.lib.file.mkOutOfStoreSymlink ../../config/alacritty/alacritty.toml;
  #
  #  # If you have any additional files or directories to include
  #  xdg.configFile."alacritty/themes" = {
  #    source = ../../config/alacritty/themes;
  #    recursive = true;
  #  };

  # Ensure the Alacritty package is installed
  # home.packages = [ pkgs.alacritty ];
}

