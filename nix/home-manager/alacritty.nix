{ config, pkgs, lib, ... }:

let
#  # Assuming the main Alacritty config file is named "alacritty.toml"
#  alacrittyConfig = config.alacritty.content."alacritty.toml" or "";
#
#  # Function to create a temporary file with the content
#  writeTemp = name: content:
#    pkgs.writeText "alacritty-${name}" content;
#
#  # Create a temporary file for the Alacritty config
#  alacrittyConfigFile = writeTemp "alacritty.toml" alacrittyConfig;

in {
  programs.alacritty = {
    enable = true;
    settings = {
      # We delegate entirely to the standard config, even
      # though we could define it here in nix, so as to
      # keep as thin a layer as possible, making us less
      # nix dependent.
#      import = [ "${alacrittyConfigFile}" ];
    };
  };
}