{
  programs.nixvim = {
    # Useful plugin to show you pending keybinds.
    # https://nix-community.github.io/nixvim/plugins/which-key/index.html
    plugins.which-key = {
      enable = true;

      # Sets the loading event to 'VimEnter'
      # event = "VimEnter";

      settings = {
        icons = {
          # set icon mappings to true if you have a Nerd Font
          mappings.__raw = "vim.g.have_nerd_font";
          # If you are using a Nerd Font: set icons.keys to an empty table which will use the
          # default which-key.nvim defined Nerd Font icons, otherwise define a string table
          keys.__raw = ''
            vim.g.have_nerd_font and {} or {
              Up = "<Up> ",
              Down = "<Down> ",
              Left = "<Left> ",
              Right = "<Right> ",
              C = "<C-…> ",
              M = "<M-…> ",
              D = "<D-…> ",
              S = "<S-…> ",
              CR = "<CR> ",
              Esc = "<Esc> ",
              ScrollWheelDown = "<ScrollWheelDown> ",
              ScrollWheelUp = "<ScrollWheelUp> ",
              NL = "<NL> ",
              BS = "<BS> ",
              Space = "<Space> ",
              Tab = "<Tab> ",
              F1 = "<F1>",
              F2 = "<F2>",
              F3 = "<F3>",
              F4 = "<F4>",
              F5 = "<F5>",
              F6 = "<F6>",
              F7 = "<F7>",
              F8 = "<F8>",
              F9 = "<F9>",
              F10 = "<F10>",
              F11 = "<F11>",
              F12 = "<F12>",
            }
          '';
        };

        # Document existing key chains
        spec = [
          {
            __unkeyed-1 = "<leader>c";
            group = "[C]ode";
            mode = [
              "n"
              "x"
            ];
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "[D]ocument";
          }
          {
            __unkeyed-1 = "<leader>r";
            group = "[R]ename";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "[S]earch";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "[W]orkspace";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "[T]oggle";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "Git [H]unk";
            mode = [
              "n"
              "v"
            ];
          }
        ];

        # You can add more settings here as needed
        # For example:
        # plugins = {};
        # operators = {};
        # motions = {};
        # ignore_missing = false;
        # hidden = {};
        # triggers = "auto";
        # triggers_nowait = {};
        # triggers_blacklist = {};
        # disable = {};
        # presets = {};
        # window = {};
        # layout = {};
      };
    };
  };
}
