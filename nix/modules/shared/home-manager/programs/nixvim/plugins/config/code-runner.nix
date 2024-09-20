{
  lib,
  helpers,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.plugins.code-runner;
in
{
  options = {
    plugins.code-runner = {
      enable = mkEnableOption "code-runner.nvim";

      package = mkPackageOption pkgs "vimPlugins.code_runner-nvim" { };

      mode = mkOption {
        type = types.enum [
          "better_term"
          "float"
          "tab"
          "toggleterm"
          "vimux"
          "term"
          "split"
        ];
        default = "float";
        description = "Mode in which you want to run the code.";
      };

      focus = mkOption {
        type = types.bool;
        default = false;
        description = "Focus on runner window. Only works on term and tab mode.";
      };

      startinsert = mkOption {
        type = types.bool;
        default = false;
        description = "Start in insert mode. Only works on term and tab mode.";
      };

      term = {
        position = mkOption {
          type = types.enum [
            "top"
            "bottom"
            "left"
            "right"
          ];
          default = "bottom";
          description = "Terminal position.";
        };

        size = mkOption {
          type = types.either types.int types.float;
          default = 10;
          description = "Size of the terminal window (int for fixed size, float for percentage).";
        };
      };

      float = {
        border = mkOption {
          type = types.enum [
            "none"
            "single"
            "double"
            "rounded"
            "solid"
            "shadow"
          ];
          default = "single";
          description = "Window border options.";
        };

        width = mkOption {
          type = types.float;
          default = 0.8;
          description = "Width of the float window.";
        };

        height = mkOption {
          type = types.float;
          default = 0.8;
          description = "Height of the float window.";
        };

        x = mkOption {
          type = types.float;
          default = 0.5;
          description = "X position of the float window.";
        };

        y = mkOption {
          type = types.float;
          default = 0.5;
          description = "Y position of the float window.";
        };
      };

      filetype = mkOption {
        type = with types; attrsOf (either str (either (listOf str) (functionTo str)));
        default = { };
        description = "Filetype configurations.";
        example = literalExpression ''
          {
            java = [
              "cd $dir &&"
              "javac $fileName &&"
              "java $fileNameWithoutExt"
            ];
            python = "python3 -u";
            typescript = "deno run";
            rust = {
              "cd $dir &&"
              "rustc $fileName &&"
              "$dir/$fileNameWithoutExt"
            };
            c = (filename: "gcc ${filename} -o /tmp/output && /tmp/output");
          }
        '';
      };

      project = mkOption {
        type =
          with types;
          attrsOf (submodule {
            options = {
              name = mkOption {
                type = types.str;
                description = "Project name.";
              };
              description = mkOption {
                type = types.str;
                description = "Project description.";
              };
              file_name = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "File name to run.";
              };
              command = mkOption {
                type = types.nullOr (types.either types.str (types.functionTo types.str));
                default = null;
                description = "Command to run the project.";
              };
            };
          });
        default = { };
        description = "Project configurations.";
      };

      before_run_filetype = mkOption {
        type = types.lines;
        default = "";
        description = "Lua function to be executed before running a file.";
      };

      keymap = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "default keymaps for code_runner";

            prefix = mkOption {
              type = types.str;
              default = "<leader>";
              description = "Prefix for code_runner keymaps.";
            };

            run_code = mkOption {
              type = types.str;
              default = "r";
              description = "Keymap for running code.";
            };

            run_file = mkOption {
              type = types.str;
              default = "rf";
              description = "Keymap for running file.";
            };

            run_project = mkOption {
              type = types.str;
              default = "rp";
              description = "Keymap for running project.";
            };

            run_close = mkOption {
              type = types.str;
              default = "rc";
              description = "Keymap for closing runner.";
            };

            custom = mkOption {
              type = with types; attrsOf str;
              default = { };
              description = "Custom keymaps for code_runner.";
              example = literalExpression ''
                {
                  "<leader>rt" = ":RunFile tab<CR>";
                  "<leader>rb" = ":RunFile toggleterm<CR>";
                }
              '';
            };
          };
        };
        default = { };
        description = "Keymap configuration for code_runner.";
      };
    };
  };

  config = mkIf cfg.enable {
    extraPlugins = [ cfg.package ];

    extraConfigLua = ''
      require('code_runner').setup({
        mode = "${cfg.mode}",
        focus = ${boolToString cfg.focus},
        startinsert = ${boolToString cfg.startinsert},
        term = {
          position = "${cfg.term.position}",
          size = ${toString cfg.term.size},
        },
        float = {
          border = "${cfg.float.border}",
          width = ${toString cfg.float.width},
          height = ${toString cfg.float.height},
          x = ${toString cfg.float.x},
          y = ${toString cfg.float.y},
        },
        filetype = ${helpers.toLuaObject cfg.filetype},
        project = ${helpers.toLuaObject cfg.project},
        before_run_filetype = function(filetype)
          ${cfg.before_run_filetype}
        end,
      })

      ${optionalString cfg.keymap.enable ''
        -- Default keymaps
        vim.keymap.set('n', '${cfg.keymap.prefix}${cfg.keymap.run_code}', ':RunCode<CR>', { noremap = true, silent = false })
        vim.keymap.set('n', '${cfg.keymap.prefix}${cfg.keymap.run_file}', ':RunFile<CR>', { noremap = true, silent = false })
        vim.keymap.set('n', '${cfg.keymap.prefix}${cfg.keymap.run_project}', ':RunProject<CR>', { noremap = true, silent = false })
        vim.keymap.set('n', '${cfg.keymap.prefix}${cfg.keymap.run_close}', ':RunClose<CR>', { noremap = true, silent = false })

        -- Custom keymaps
        ${concatStringsSep "\n" (
          mapAttrsToList (key: cmd: ''
            vim.keymap.set('n', '${key}', '${cmd}', { noremap = true, silent = false })
          '') cfg.keymap.custom
        )}
      ''}
    '';
  };
}
