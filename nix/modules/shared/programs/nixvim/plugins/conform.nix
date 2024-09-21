# NixVim Configuration with Conform.nvim Integration
#
# This configuration sets up the Conform.nvim plugin for NixVim,
# providing autoformatting capabilities for various file types.
#
# References:
# - NixVim: https://nix-community.github.io/nixvim/
# - Conform.nvim: https://github.com/stevearc/conform.nvim
# - NixVim Conform.nvim docs: https://nix-community.github.io/nixvim/plugins/conform-nvim.html

{ pkgs, ... }:
{
  programs.nixvim = {
    # Extra packages required for formatting
    # https://nix-community.github.io/nixvim/options/#extrapackages
    extraPackages = with pkgs; [
      stylua # Lua formatter
      black # Python formatter
      isort # Python import sorter
      nixfmt-rfc-style # Nix formatter
      # Add other formatters as needed, e.g.:
      # nodePackages.prettier  # JavaScript/TypeScript formatter
      # rustfmt                # Rust formatter
    ];

    # Conform.nvim configuration
    plugins.conform-nvim = {
      enable = true;
      settings.notify_on_error = false;

      # Format on save configuration
      # https://github.com/stevearc/conform.nvim#format-on-save
      settings.format_on_save = ''
        function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = "never"
          else
            lsp_format_opt = "fallback"
          end
          return {
            timeout_ms = 500,
            lsp_fallback = lsp_format_opt,
          }
        end
      '';

      # Formatter configurations by file type
      # https://github.com/stevearc/conform.nvim#formatters
      settings.formatters_by_ft = {
        lua = [ "stylua" ];
        python = [
          "isort"
          "black"
        ]; # Run multiple formatters sequentially
        nix = [ "nixfmt" ];
        # Add more file types and their respective formatters as needed
        # Example: Run formatters until one succeeds
        # javascript = [ [ "prettierd" "prettier" ] ];
      };
    };

    # Keymaps for manual formatting
    # https://nix-community.github.io/nixvim/keymaps/
    keymaps = [
      {
        mode = ""; # Works in normal, visual, and select modes
        key = "<leader>f";
        action.__raw = ''
          function()
            require("conform").format({ async = true, lsp_fallback = true })
          end
        '';
        options = {
          desc = "[F]ormat buffer";
        };
      }
    ];

    # You can add more NixVim configurations here, such as:
    # - LSP settings
    # - Additional plugins
    # - Vim options
    # - etc.
  };
}
