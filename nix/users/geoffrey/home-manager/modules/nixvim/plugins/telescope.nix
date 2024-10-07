{
  programs.nixvim = {
    # Fuzzy Finder (files, lsp, etc)
    # https://nix-community.github.io/nixvim/plugins/telescope/index.html
    plugins.telescope = {
      # Telescope is a fuzzy finder that comes with a lot of different things that
      # it can fuzzy find! It's more than just a "file finder", it can search
      # many different aspects of Neovim, your workspace, LSP, and more!
      #
      # The easiest way to use Telescope, is to start by doing something like:
      #  :Telescope help_tags
      #
      # After running this command, a window will open up and you're able to
      # type in the prompt window. You'll see a list of `help_tags` options and
      # a corresponding preview of the help.
      #
      # Two important keymaps to use while in Telescope are:
      #  - Insert mode: <c-/>
      #  - Normal mode: ?
      #
      # This opens a window that shows you all of the keymaps for the current
      # Telescope picker. This is really useful to discover what Telescope can
      # do as well as how to actually do it!
      #
      # [[ Configure Telescope ]]
      # See `:help telescope` and `:help telescope.setup()`
      enable = true;

      # Enable Telescope extensions
      extensions = {
        fzf-native.enable = true;
        ui-select.enable = true;
      };

      # You can put your default mappings / updates / etc. in here
      #  See `:help telescope.builtin`
      keymaps = {
        #        "<C-j>" = {
        #          mode = "n";
        #          action = "move_selection_next";
        #          options.desc = "Move selection [D]own";
        #        };
        #        "<C-k>" = {
        #          mode = "n";
        #          action = "move_selection_previous";
        #          options.desc = "Move selection [U]p";
        #        };
        #        "<C-n>" = {
        #          mode = "n";
        #          action = "cycle_history_next";
        #          options.desc = "Cycle [N]ext history";
        #        };
        #        "<C-p>" = {
        #          mode = "n";
        #          action = "cycle_history_prev";
        #          options.desc = "Cycle [P]revious history";
        #        };
        #        "<C-c>" = {
        #          mode = "n";
        #          action = "close";
        #          options.desc = "[C]lose";
        #        };
        #        "<C-q>" = {
        #          mode = "n";
        #          action = "smart_send_to_qflist";
        #          options.desc = "[Q]uickfix";
        #        };
        "<leader>fr" = {
          mode = "n";
          action = "lsp_references";
          options.desc = "[F]ind [R]eferences";
        };
        "<leader>sh" = {
          mode = "n";
          action = "help_tags";
          options.desc = "[S]earch [H]elp";
        };
        "<leader>sk" = {
          mode = "n";
          action = "keymaps";
          options.desc = "[S]earch [K]eymaps";
        };
        "<leader>sf" = {
          mode = "n";
          action = "find_files";
          options.desc = "[S]earch [F]iles";
        };
        "<leader>ss" = {
          mode = "n";
          action = "builtin";
          options.desc = "[S]earch [S]elect Telescope";
        };
        "<leader>sw" = {
          mode = "n";
          action = "grep_string";
          options.desc = "[S]earch current [W]ord";
        };
        "<leader>sg" = {
          mode = "n";
          action = "live_grep";
          options.desc = "[S]earch by [G]rep";
        };
        "<leader>sd" = {
          mode = "n";
          action = "diagnostics";
          options.desc = "[S]earch [D]iagnostics";
        };
        "<leader>sr" = {
          mode = "n";
          action = "resume";
          options.desc = "[S]earch [R]esume";
        };
        "<leader>s." = {
          mode = "n";
          action = "oldfiles";
          options.desc = "[S]earch Recent Files ('.' for repeat)";
        };
        "<leader><leader>" = {
          mode = "n";
          action = "buffers";
          options.desc = "[ ] Find existing buffers";
        };
      };

      settings = {
        # Configure Telescope extensions
        extensions.__raw = ''
          {
            ['ui-select'] = require('telescope.themes').get_dropdown(),
            -- You can add more extension configurations here if needed
          }
        '';

        # Additional Telescope settings
        defaults = {
          # You can add default settings here
          # For example:
          # file_ignore_patterns = [ "node_modules" "%.git" ];
          # layout_strategy = "horizontal";
        };

        # Picker-specific settings
        pickers = {
          # You can customize specific pickers here
          # For example:
          # find_files = {
          #   hidden = true;
          # };
        };
      };
    };

    # https://nix-community.github.io/nixvim/keymaps/index.html
    keymaps = [
      # Slightly advanced example of overriding default behavior and theme
      {
        mode = "n";
        key = "<leader>/";
        # You can pass additional configuration to Telescope to change the theme, layout, etc.
        action.__raw = ''
          function()
            require('telescope.builtin').current_buffer_fuzzy_find(
              require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false
              }
            )
          end
        '';
        options.desc = "[/] Fuzzily search in current buffer";
      }
      {
        mode = "n";
        key = "<leader>s/";
        # It's also possible to pass additional configuration options.
        #  See `:help telescope.builtin.live_grep()` for information about particular keys
        action.__raw = ''
          function()
            require('telescope.builtin').live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files'
            }
          end
        '';
        options.desc = "[S]earch [/] in Open Files";
      }
      # Shortcut for searching your Neovim configuration files
      {
        mode = "n";
        key = "<leader>sn";
        action.__raw = ''
          function()
            require('telescope.builtin').find_files {
              cwd = vim.fn.stdpath 'config'
            }
          end
        '';
        options.desc = "[S]earch [N]eovim files";
      }
    ];

    # Additional Lua configuration for Telescope
    extraConfigLua = ''
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
      }

      -- Enable Telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      -- Enable Telescope ui-select, if installed
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')

      -- You can add more custom Lua functions or configurations here if needed
    '';
  };
}
