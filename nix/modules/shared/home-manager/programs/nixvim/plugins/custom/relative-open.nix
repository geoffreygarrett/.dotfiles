{ pkgs, ... }:
{
  programs.nixvim = {
    extraConfigLua = ''
      -- Function to open a file relative to the current file
      local function edit_relative(command)
        return function()
          local current_dir = vim.fn.expand('%:p:h')
          local relative_path = vim.fn.input("Enter relative file path: ", "", "file")
          if relative_path ~= "" then
            local full_path = current_dir .. '/' .. relative_path
            vim.cmd(command .. ' ' .. vim.fn.fnameescape(full_path))
          end
        end
      end

      -- Key mappings for relative file opening
      vim.keymap.set('n', '<leader>re', edit_relative('edit'), { desc = "Edit file relative to current" })
      vim.keymap.set('n', '<leader>rv', edit_relative('vsplit'), { desc = "Vertical split file relative to current" })
      vim.keymap.set('n', '<leader>rs', edit_relative('split'), { desc = "Horizontal split file relative to current" })
      vim.keymap.set('n', '<leader>rt', edit_relative('tabedit'), { desc = "Open in new tab file relative to current" })

      -- Command to change directory to current file's directory
      vim.api.nvim_create_user_command('CDC', 'cd %:p:h', { desc = "Change directory to current file's directory" })
    '';
  };
}
