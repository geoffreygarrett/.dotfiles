{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.tmux-sessionizer;
in
{
  options.programs.tmux-sessionizer = {
    enable = mkEnableOption "tmux-sessionizer";

    package = mkOption {
      type = types.package;
      default = pkgs.tmux-sessionizer;
      description = "The tmux-sessionizer package to use.";
    };

    defaultSession = mkOption {
      type = types.str;
      default = "main";
      description = "The default session name.";
    };

    displayFullPath = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to display the full path.";
    };

    searchSubmodules = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to search submodules.";
    };

    recursiveSubmodules = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to recursively search submodules.";
    };

    switchFilterUnknown = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to filter unknown sessions when switching.";
    };

    sessionSortOrder = mkOption {
      type = types.enum [
        "LastAttached"
        "Alphabetical"
        "Custom"
      ];
      default = "LastAttached";
      description = "The sort order for sessions.";
    };

    excludedDirs = mkOption {
      type = types.listOf types.str;
      default = [
        ".git"
        "node_modules"
        "dist"
      ];
      description = "Directories to exclude from search.";
    };

    searchDirs = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "The path to search.";
            };
            depth = mkOption {
              type = types.int;
              default = 1;
              description = "The search depth.";
            };
          };
        }
      );
      default = [
        {
          path = "${config.home.homeDirectory}/.dotfiles";
          depth = 1;
        }
        {
          path = "${config.home.homeDirectory}/Projects";
          depth = 1;
        }
      ];
      description = "Directories to search, with their respective depths.";
    };

    pickerColors = mkOption {
      type = types.submodule {
        options = {
          highlightColor = mkOption {
            type = types.str;
            default = "#2E3440";
            description = "The highlight color.";
          };
          highlightTextColor = mkOption {
            type = types.str;
            default = "#eeffff";
            description = "The highlight text color.";
          };
          borderColor = mkOption {
            type = types.str;
            default = "#0F111A";
            description = "The border color.";
          };
          infoColor = mkOption {
            type = types.str;
            default = "#717CB4";
            description = "The info text color.";
          };
          promptColor = mkOption {
            type = types.str;
            default = "#84ffff";
            description = "The prompt color.";
          };
        };
      };
      default = { };
      description = "Picker colors configuration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".config/tms/config.toml".text = ''
      # General settings
      default_session = "${cfg.defaultSession}"
      display_full_path = ${boolToString cfg.displayFullPath}
      search_submodules = ${boolToString cfg.searchSubmodules}
      recursive_submodules = ${boolToString cfg.recursiveSubmodules}
      switch_filter_unknown = ${boolToString cfg.switchFilterUnknown}
      session_sort_order = "${cfg.sessionSortOrder}"
      # Excluded directories
      excluded_dirs = [
        ${concatMapStringsSep ",\n  " (dir: "\"${dir}\"") cfg.excludedDirs}
      ]
      # Search directories
      search_dirs = [
        ${concatMapStringsSep ",\n  " (dir: "[\"${dir.path}\", ${toString dir.depth}]") cfg.searchDirs}
      ]
      # Picker colors
      [picker_colors]
      highlight_color = "${cfg.pickerColors.highlightColor}"
      highlight_text_color = "${cfg.pickerColors.highlightTextColor}"
      border_color = "${cfg.pickerColors.borderColor}"
      info_color = "${cfg.pickerColors.infoColor}"
      prompt_color = "${cfg.pickerColors.promptColor}"
    '';
  };
}
