{ pkgs, ... }:
{

  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      nixvimInjections = true;
      folding = false;

      settings = {
        # Ensure these languages are installed
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
          "rust"
          "toml"
          "typescript"
          "javascript"
          "sql"
          "tsx"
          "tmux"
          "nix"
        ];
        autoInstall = true;

        # Register SQL language
        languageRegister = {
          sql = "sql";
        };

        # Basic treesitter configuration
        highlight = {
          enable = true;
          additionalVimRegexHighlighting = [
            "ruby"
            "rust"
          ];
        };
        incremental_selection.enable = true;
        indent = {
          enable = true;
          disable = [ "ruby" ];
        };

      };
    };

    # Add Tree-sitter Playground plugin for debugging
    extraPlugins = [
      pkgs.vimPlugins.playground
    ];

    extraConfigLua = ''
      vim.treesitter.query.set("rust", "injections", [[
        ((string_literal
          (string_content) @injection.content)
        (#match? @injection.content "^\\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|select|insert|update|delete|create|alter|drop)")
        (#set! injection.language "sql"))
        ((raw_string_literal
          (string_content) @injection.content)
        (#match? @injection.content "^\\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|select|insert|update|delete|create|alter|drop)")
        (#set! injection.language "sql"))
      ]])
    '';

    # extraConfig:Lua = ''
    #   vim.treesitter.query.set("rust", "injections", [[
    #     ; SQL injection based on language comment
    #     (
    #       (line_comment) @language
    #       .
    #       [
    #         (raw_string_literal (string_content) @injection.content)
    #         (string_literal (string_content) @injection.content)
    #       ]
    #       (#match? @language "^\\s*//\\s*language=sql\\s*$")
    #       (#set! injection.language "sql")
    #     )
    #       ; SQL injection based on language comment
    #     (
    #       (function_item
    #         body: (block
    #           (line_comment) @language
    #           .
    #           [
    #             (raw_string_literal (string_content) @injection.content)
    #             (string_literal (string_content) @injection.content)
    #           ]
    #         )
    #       )
    #       (#match? @language "^\\s*//\\s*language=sql\\s*$")
    #       (#set! injection.language "sql")
    #     )
    #   ]])
    # '';
    # extraConfigLua = ''
    #   -- Function to set language injection based on comments
    #   local function set_injection_with_tag(lang, tag)
    #     vim.treesitter.query.set('rust', 'injections', string.format([[
    #       ; Language injection for %s
    #       (
    #         (line_comment) @language
    #         .
    #         [
    #           (string_literal (string_content) @injection.content)
    #           (raw_string_literal (string_content) @injection.content)
    #         ]
    #         (#match? @language "^\\s*//\\s*%s\\s*$")
    #         (#set! injection.language "%s")
    #       )
    #     ]], lang, tag, lang))
    #   end
    #
    #   -- Set up injections for different languages
    #   set_injection_with_tag("sql", "language=sql")
    #   set_injection_with_tag("python", "language=python")
    #
    #   -- Add more languages as needed:
    #   -- set_injection_with_tag("javascript", "language=js")
    #   -- set_injection_with_tag("html", "language=html")
    #   -- set_injection_with_tag("css", "language=css")
    #
    #   -- Automatic SQL detection (uncomment to enable)
    #   --[[ 
    #   vim.treesitter.query.set('rust', 'injections', [=[
    #     ; Automatic SQL detection in raw string literals
    #     (
    #       (raw_string_literal
    #         (string_content) @injection.content)
    #       (#match? @injection.content "^\\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP)")
    #       (#set! injection.language "sql")
    #     )
    #   ]=])
    #   ]]
    # ''; # Commented out templates for future use or reference
    # extraConfigLua = ''
    #   -- Example of using luasnip for filetype extensions
    #   local injections = require('luasnip.extras.filetype_functions').extend_load_ft({
    #     rust = { 'sql' }
    #   })
    #
    #   -- Alternative treesitter setup
    #   require('nvim-treesitter.configs').setup {
    #     highlight = {
    #       enable = true,
    #       additional_vim_regex_highlighting = { 'ruby' },
    #     },
    #     indent = {
    #       enable = true,
    #       disable = { 'ruby' },
    #     },
    #     ensure_installed = { 'rust', 'sql' },
    #     injections = {
    #       enable = true,
    #     },
    #   }
    #
    #   -- Alternative injection query
    #   vim.treesitter.query.set('rust', 'injections', [[
    #     ((line_comment) @_comment (#match? @_comment "^//!?\\s*sql")
    #      .
    #      (raw_string_literal) @injection.content
    #      (#set! injection.language "sql"))
    #   ]])
    #
    #   -- Enable tmux highlighting within Nix strings (has unintended effects throughout nix code)
    #   -- vim.treesitter.language.register('tmux', 'nix')
    # '';

    # Uncomment if you want to ensure Treesitter is updated
    # extraConfigLua = ''
    #   vim.cmd('TSUpdate')
    # '';
  };
}
