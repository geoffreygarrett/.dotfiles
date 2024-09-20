{ pkgs, ... }:
let
  code-runner-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "duck-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "CRAG666";
      repo = "code_runner.nvim";
      rev = "dcedccbf969a0f3bc00db446172b4966e83101dd";
      sha256 = "0n6vv6nwslr5agy2xdlq4gnhl7vawbs4qzwnwg2156qgdg5b85f7";
    };
  };
in
{

  programs.nixvim = {
    extraPlugins = [
      code-runner-nvim
    ];

    extraConfigLua = ''
      -- Code Runner Configuration
      -- https://github.com/CRAG666/code_runner.nvim

      require('code_runner').setup({
        -- Mode in which you want to run. Supported modes: "better_term", "float", "tab", "toggleterm", "vimux"
        -- https://github.com/CRAG666/code_runner.nvim#mode
        mode = "float",

        -- Focus on runner window. Only works on term and tab mode
        -- https://github.com/CRAG666/code_runner.nvim#focus
        focus = false,

        -- Start in insert mode. Only works on term and tab mode
        -- https://github.com/CRAG666/code_runner.nvim#startinsert
        startinsert = false,

        -- Configurations for the integrated terminal
        -- https://github.com/CRAG666/code_runner.nvim#term
        term = {
          position = "bot",
          size = 8,
        },

        -- Configurations for the float window
        -- https://github.com/CRAG666/code_runner.nvim#float
        float = {
          border = "single",
          width = 0.8,
          height = 0.8,
          x = 0.5,
          y = 0.5,
        },

        -- Filetype configurations
        -- https://github.com/CRAG666/code_runner.nvim#setup-filetypes
        filetype = {
          java = {
            "cd $dir &&",
            "javac $fileName &&",
            "java $fileNameWithoutExt"
          },
          python = "python3 -u",
          typescript = "deno run",
          rust = {
            "cd $dir &&",
            "rustc $fileName &&",
            "$dir/$fileNameWithoutExt"
          },
          -- Add more filetypes as needed
        },

        -- Project configurations
        -- https://github.com/CRAG666/code_runner.nvim#setup-projects
        project = {
          -- Uncomment and modify these as needed
          -- ["~/python/project1"] = {
          --   name = "My Python Project",
          --   description = "A sample Python project",
          --   file_name = "src/main.py"
          -- },
          -- ["~/rust/project2"] = {
          --   name = "Rust Project",
          --   description = "A Rust project example",
          --   command = "cargo run"
          -- },
        },

        -- Before run hook
        -- https://github.com/CRAG666/code_runner.nvim#before_run_filetype
        before_run_filetype = function(filetype)
          -- Add any pre-run logic here
          print("Running " .. filetype .. " file")
        end,
      })

      -- Keymaps
      -- https://github.com/CRAG666/code_runner.nvim#recommended-mappings
      vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })

      -- Additional Lua configuration can be added here
    '';
  };
}
