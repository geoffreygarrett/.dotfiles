{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.harpoon.enable = true;
    # plugins.harpoon = {
    #   enable = true;
    #   enableTelescope = true;
    #   keymapsSilent = true;
    #   keymaps = {
    #     addFile = "<leader>ha";
    #     toggleQuickMenu = "<leader>hm";
    #     navFile = {
    #       "1" = "<leader>h1";
    #       "2" = "<leader>h2";
    #       "3" = "<leader>h3";
    #       "4" = "<leader>h4";
    #     };
    #     navNext = "<leader>hn";
    #     navPrev = "<leader>hp";
    #     cmdToggleQuickMenu = "<leader>hc";
    #   };
    # };

    extraConfigLua = ''
      local harpoon = require("harpoon")

      -- Harpoon setup
      harpoon.setup({
        global_settings = {
          save_on_toggle = false,
          save_on_change = true,
          enter_on_sendcmd = false,
          tmux_autoclose_windows = false,
          excluded_filetypes = { "harpoon" },
          mark_branch = true,
          tabline = true,
          tabline_prefix = "   ",
          tabline_suffix = "   ",
        },
        menu = {
          width = vim.api.nvim_win_get_width(0) - 4,
        }
      })

      -- Key mappings
      vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = "[H]arpoon: [A]dd file" })
      vim.keymap.set('n', '<leader>hm', require('harpoon.ui').toggle_quick_menu, { desc = "[H]arpoon: Toggle [M]enu" })
      vim.keymap.set('n', '<leader>hc', require('harpoon.cmd-ui').toggle_quick_menu, { desc = "[H]arpoon: Toggle [C]ommand menu" })

      -- Navigation
      vim.keymap.set('n', '<leader>hn', require('harpoon.ui').nav_next, { desc = "[H]arpoon: [N]ext mark" })
      vim.keymap.set('n', '<leader>hp', require('harpoon.ui').nav_prev, { desc = "[H]arpoon: [P]revious mark" })

      for i = 1, 4 do
        vim.keymap.set('n', string.format('<leader>h%s', i),
          function() require('harpoon.ui').nav_file(i) end,
          { desc = string.format("[H]arpoon: Go to file %s", i) }
        )
      end

      -- Terminal commands (example)
      vim.keymap.set('n', '<leader>ht1', function() require('harpoon.term').gotoTerminal(1) end, { desc = "[H]arpoon: Go to [T]erminal 1" })
      vim.keymap.set('n', '<leader>ht2', function() require('harpoon.term').gotoTerminal(2) end, { desc = "[H]arpoon: Go to [T]erminal 2" })

      -- Send a command to a terminal (example)
      vim.keymap.set('n', '<leader>hsc', function() require('harpoon.term').sendCommand(1, 'ls -la') end, { desc = "[H]arpoon: [S]end [C]ommand to terminal 1" })

      -- Telescope integration
      require('telescope').load_extension('harpoon')
      vim.keymap.set('n', '<leader>hf', "<cmd>Telescope harpoon marks<CR>", { desc = "[H]arpoon: [F]ind marks in Telescope" })

      -- Custom highlights for tabline (optional)
      vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#63698c')
      vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
      vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7')
      vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7')
      vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
    '';
  };
}
