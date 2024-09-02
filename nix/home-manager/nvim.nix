{ config, pkgs, lib, ... }:

let
  configDir = ../../config/nvim;
  nvimFiles = builtins.readDir configDir;

  # Function to create a file or directory attribute
  mkConfigAttr = name: type: lib.nameValuePair
    "nvim/${name}"
    (if type == "directory"
     then { source = "${configDir}/${name}"; recursive = true; }
     else { text = builtins.readFile "${configDir}/${name}"; });

  # Convert the list of files and directories to a set of attributes
  nvimConfigFiles = lib.mapAttrs' mkConfigAttr nvimFiles;

in {
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    # Optionally, specify plugins here
    plugins = with pkgs.vimPlugins; [
      # Add your plugins here, for example:
      # vim-nix
      # nvim-treesitter
    ];

    # Any additional Neovim configuration can go here
    extraConfig = ''
      " Any Vimscript configuration can go here
    '';
  };

  # Import all files and directories from the config directory
  xdg.configFile = nvimConfigFiles;

  # If you have any executables or scripts, you might want to add them to PATH
  home.sessionPath = [
    "${config.xdg.configHome}/nvim/bin"
  ];
}