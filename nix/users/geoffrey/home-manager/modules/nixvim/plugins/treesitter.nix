{
  programs.nixvim = {
    # Highlight, edit, and navigate code
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter = {
      enable = true;
      # TODO: Don't think I need this as nixGrammars is true which should auto install these???
      settings = {
        ensureInstalled = [
          "bash"
          "c"
          "diff"
          "html"
          "lua"
          "luadoc"
          "markdown"
          "markdown_inline"
          "query"
          "vim"
          "vimdoc"
          # Additional languages from Lua config
          "rust"
          "toml"
          "typescript"
          "javascript"
          "sql"
          "tsx"
          "tmux"
        ];
        autoInstall = true;
        highlight = {
          enable = true;
          # Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          # If you are experiencing weird indenting issues, add the language to
          # the list of additional_vim_regex_highlighting and disabled languages for indent.
          additionalVimRegexHighlighting = [ "ruby" ];
        };
        indent = {
          enable = true;
          disable = [ "ruby" ];
        };
        injections = {
          enable = true;
          # Specify custom injection files located at `../../scm/injections.scm`
          custom_injections = "../../scm/injections.scm"; # Update this to your actual path
        };
        # There are additional nvim-treesitter modules that you can use to interact
        # with nvim-treesitter. You should go explore a few and see what interests you:
        #
        #    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        #    - Show your current context: https://nix-community.github.io/nixvim/plugins/treesitter-context/index.html
        #    - Treesitter + textobjects: https://nix-community.github.io/nixvim/plugins/treesitter-textobjects/index.html
      };
    };

    # Add this if you want to ensure Treesitter is updated
    #    extraConfigLua = ''
    #      vim.cmd('TSUpdate')
    #    '';

    extraConfigLua = ''
      -- Enable tmux highlighting within Nix strings (has unintended effects throughout nix code)
      -- vim.treesitter.language.register('tmux', 'nix')
    '';
  };
}
