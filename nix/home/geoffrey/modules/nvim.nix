{ config, pkgs, lib, inputs, ... }:
let
  # Define a script that returns either the GitHub token or OpenAI API key
  key-fetcher = pkgs.writeShellScriptBin "key-fetcher" ''
    #!/bin/sh

    # Function to return the key based on the file path
    fetch_key() {
      if [ -f "$1" ]; then
        cat "$1"
      else
        echo "Error: $2 not found."
        exit 1
      fi
    }

    # Determine which key to return based on the argument
    case "$1" in
      "github-token")
        fetch_key "${config.sops.secrets.github_token.path}" "GitHub token"
        ;;
      "openai-api-key")
        fetch_key "${config.sops.secrets.openai_api_key.path}" "OpenAI API key"
        ;;
      *)
        echo "Usage: $0 {github-token|openai-api-key}"
        exit 1
        ;;
    esac
  '';
in
{
  sops.secrets.openai_api_key = {
    sopsFile = config.sops.defaultSopsFile;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " Any Vimscript configuration can go here
    '';
  };
  home.packages = [ pkgs.lazygit ];
  xdg.configFile."nvim" = {
    source = "${inputs.self}/dotfiles/nvim";
    recursive = true;
  };

  xdg.configFile."nvim/lua/plugins/chatgpt.lua".source = pkgs.writeText "chatgpt.lua" ''
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

