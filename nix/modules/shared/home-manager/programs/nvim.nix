{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Define a script that returns either the GitHub token or OpenAI API key
  #language=sh
  key-fetcher =
    if
      pkgs.lib.hasAttrByPath [
        "sops"
        "secrets"
      ] config
    then
      pkgs.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        fetch_key() {
          if [ -z "$1" ]; then
            echo "Error: Secret path for $2 is not defined."
            exit 1
          elif [ -f "$1" ]; then
            cat "$1"
          else
            echo "Error: $2 not found at $1."
            exit 1
          fi
        }
        case "$1" in
          "github-token")
            fetch_key "${
              if
                pkgs.lib.hasAttrByPath [
                  "sops"
                  "secrets"
                  "github-token"
                  "path"
                ] config
              then
                config.sops.secrets.github-token.path
              else
                ""
            }" "GitHub token"
            ;;
          "openai-api-key")
            fetch_key "${
              if
                pkgs.lib.hasAttrByPath [
                  "sops"
                  "secrets"
                  "openai-api-key"
                  "path"
                ] config
              then
                config.sops.secrets.openai-api-key.path
              else
                ""
            }" "OpenAI API key"
            ;;
          *)
            echo "Usage: $0 {github-token|openai-api-key}"
            exit 1
            ;;
        esac
      ''
    else
      pkgs.writeShellScriptBin "key-fetcher" ''
        #!/bin/sh
        echo "Error: sops secrets are not configured."
        exit 1
      '';
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ripgrep # Requirement for telescope
    ];
  };
  #  home.packages = [ pkgs.lazygit ];
  xdg.configFile."nvim" = {
    source = "${inputs.self}/dotfiles/nvim";
    recursive = true;
  };

  xdg.configFile."nvim/lua/plugins/chatgpt.lua".source =
    #language=lua
    pkgs.writeText "chatgpt.lua" ''
      return {
          "jackMort/ChatGPT.nvim",
          event = "VeryLazy",
          config = function()
              require("chatgpt").setup({
                  api_key_cmd = '${key-fetcher}/bin/key-fetcher openai-api-key',
              })
          end,
          dependencies = {
              "MunifTanjim/nui.nvim",
              "nvim-lua/plenary.nvim",
              "folke/trouble.nvim",
              "nvim-telescope/telescope.nvim",
          },
      }
    '';
}
