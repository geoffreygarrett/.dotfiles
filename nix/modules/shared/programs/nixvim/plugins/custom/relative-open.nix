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

      -- Key mappings for [R] operations
      vim.keymap.set('n', '<leader>r', '<nop>', { desc = "[R]elative/Rename operations" })

      -- Key mappings for relative file opening
      vim.keymap.set('n', '<leader>re', edit_relative('edit'), { desc = "[R]elative: [E]dit file" })
      vim.keymap.set('n', '<leader>rv', edit_relative('vsplit'), { desc = "[R]elative: [V]ertical split file" })
      vim.keymap.set('n', '<leader>rs', edit_relative('split'), { desc = "[R]elative: [S]plit file horizontally" })
      vim.keymap.set('n', '<leader>rt', edit_relative('tabedit'), { desc = "[R]elative: Open file in new [T]ab" })

      -- Command to change directory to current file's directory
      vim.api.nvim_create_user_command('CDC', 'cd %:p:h', { desc = "[C]hange [D]irectory to [C]urrent file's location" })
    '';
  };
}
