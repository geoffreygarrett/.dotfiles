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

  lazy-nix-helper-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "lazy-nix-helper.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "b-src";
      repo = "lazy-nix-helper.nvim";
      rev = "v0.6.0";
      sha256 = "1dw514yzwpz7jw6hsgqr6kyiyn69722436bkgqb5bm53ckgww2hz";
    };
  };

  sanitizePluginName =
    input:
    let
      name = lib.strings.getName input;
      intermediate = lib.strings.removePrefix "vimplugin-" name;
      result = lib.strings.removePrefix "lua5.1-" intermediate;
    in
    result;

  pluginList =
    plugins:
    lib.strings.concatMapStrings (
      plugin: "  [\"${sanitizePluginName plugin.name}\"] = \"${plugin.outPath}\",\n"
    ) plugins;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ripgrep # Requirement for telescope
      lua-language-server
      nil
      stylua
      bash-language-server
      rust-analyzer # Add this line
      #         <lsps, etc.>
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nix-helper-nvim
      lazy-nvim
      #  <other plugins>
    ];

    extraLuaConfig = ''
              local plugins = {
              ${pluginList config.programs.neovim.plugins}
              }
              local lazy_nix_helper_path = "${lazy-nix-helper-nvim}"
              if not vim.loop.fs_stat(lazy_nix_helper_path) then
              lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy_nix_helper/lazy_nix_helper.nvim"
              if not vim.loop.fs_stat(lazy_nix_helper_path) then
                vim.fn.system({
                  "git",
                  "clone",
                  "--filter=blob:none",
                  "https://github.com/b-src/lazy_nix_helper.nvim.git",
                  lazy_nix_helper_path,
                })
              end
              end

              -- add the Lazy Nix Helper plugin to the vim runtime
              vim.opt.rtp:prepend(lazy_nix_helper_path)

              -- call the Lazy Nix Helper setup function
              local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
              local lazy_nix_helper_opts = { lazypath = non_nix_lazypath, input_plugin_table = plugins }
              require("lazy-nix-helper").setup(lazy_nix_helper_opts)

              -- get the lazypath from Lazy Nix Helper
              local lazypath = require("lazy-nix-helper").lazypath()
              if not vim.loop.fs_stat(lazypath) then
              vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
              })
              end
              vim.opt.rtp:prepend(lazypath)

              -- <additional config in init.lua>
      ${builtins.readFile "${inputs.self}/dotfiles/nvim/init.lua"}
    '';
  };
  #  home.packages = [ pkgs.lazygit ];
  # xdg.configFile."nvim" = {
  #   source = "${inputs.self}/dotfiles/nvim";
  #   recursive = true;
  # };

  xdg.configFile."nvim/lua" = {
    source = "${inputs.self}/dotfiles/nvim/lua";
    recursive = true;
  };

  xdg.configFile."nvim/scm" = {
    source = "${inputs.self}/dotfiles/nvim/scm";
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
