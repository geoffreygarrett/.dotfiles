{
  programs.nixvim = {
    plugins.oil = {
      enable = true;

      settings = {
        # Your current settings
        default_file_explorer = true;
        columns = [ "icon" ];
        buf_options = {
          buflisted = false;
          bufhidden = "hide";
        };
        win_options = {
          wrap = false;
          signcolumn = "no";
          cursorcolumn = false;
          foldcolumn = "0";
          spell = false;
          list = false;
          conceallevel = 3;
          concealcursor = "nvic";
        };
        delete_to_trash = false;
        skip_confirm_for_simple_edits = false;
        prompt_save_on_select_new_entry = true;
        cleanup_delay_ms = 2000;
        constrain_cursor = "editable";
        experimental_watch_for_changes = false;

        keymaps = {
          "g?" = "actions.show_help";
          "<CR>" = "actions.select";
          "<C-s>" = {
            callback = ''
              function()
                require("oil.actions").select({ vertical = true })
              end
            '';
            desc = "Open the entry in a vertical split";
          };
          "<C-h>" = {
            callback = ''
              function()
                require("oil.actions").select({ horizontal = true })
              end
            '';
            desc = "Open the entry in a horizontal split";
          };
          "<C-t>" = {
            callback = ''
              function()
                require("oil.actions").select({ tab = true })
              end
            '';
            desc = "Open the entry in new tab";
          };
          "<C-p>" = "actions.preview";
          "<C-c>" = "actions.close";
          "<C-l>" = "actions.refresh";
          "-" = "actions.parent";
          "_" = "actions.open_cwd";
          "`" = "actions.cd";
          "~" = {
            callback = ''
              function()
                require("oil.actions").cd({ scope = "tab" })
              end
            '';
            desc = ":tcd to the current oil directory";
          };
          "gs" = "actions.change_sort";
          "gx" = "actions.open_external";
          "g." = "actions.toggle_hidden";
          "g\\" = "actions.toggle_trash";
        };
        use_default_keymaps = true;

        view_options = {
          show_hidden = false;
          is_hidden_file = ''
            function(name, bufnr)
              return vim.startswith(name, ".")
            end
          '';
          is_always_hidden = ''
            function(name, bufnr)
              return false
            end
          '';
          natural_order = true;
          sort = [
            ["type" "asc"]
            ["name" "asc"]
          ];
        };

        # Additional available options (commented out)
        # lsp_file_method = {
        #   timeout_ms = 1000;
        #   autosave_changes = false;
        # };

        # float = {
        #   padding = 2;
        #   max_width = 0;
        #   max_height = 0;
        #   border = "rounded";
        #   win_options = {
        #     winblend = 0;
        #   };
        #   override = ''
        #     function(conf)
        #       return conf
        #     end
        #   '';
        # };

        # preview = {
        #   max_width = 0.9;
        #   min_width = [40 0.4];
        #   width = null;
        #   max_height = 0.9;
        #   min_height = [5 0.1];
        #   height = null;
        #   border = "rounded";
        #   win_options = {
        #     winblend = 0;
        #   };
        #   update_on_cursor_moved = true;
        # };

        # progress = {
        #   max_width = 0.9;
        #   min_width = [40 0.4];
        #   width = null;
        #   max_height = [10 0.9];
        #   min_height = [5 0.1];
        #   height = null;
        #   border = "rounded";
        #   minimized_border = "none";
        #   win_options = {
        #     winblend = 0;
        #   };
        # };

        # ssh = {
        #   border = "rounded";
        # };

        # keymaps_help = {
        #   border = "rounded";
        # };
      };
    };

    # Keymaps outside of the plugin configuration
    keymaps = [
      {
        mode = "n";
        key = "=";
        action = "<cmd>Oil<cr>";
        options.desc = "Open Filesystem";
      }
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil --float<cr>";
        options.desc = "Open Floating Filesystem";
      }
    ];
  };
}
