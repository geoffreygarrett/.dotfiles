{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  shellAliasesConfig = import ./shell-aliases.nix { inherit pkgs lib; };
in
{
  programs.direnv = {
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initExtraFirst = ''
      # Load Nix daemon if available
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Platform-specific aliases
      if [[ "$(uname)" == "Linux" ]]; then
        alias pbcopy='xclip -selection clipboard'
      fi

      # PATH modifications
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.npm-packages/bin:$HOME/.composer/vendor/bin:$HOME/.local/share/bin:$HOME/bin:$PATH

      # PNPM configuration
      export PNPM_HOME=~/.pnpm-packages
      alias pn=pnpm
      alias px=pnpx

      # Custom aliases
      alias search='rg -p --glob "!node_modules/*" --glob "!vendor/*"'
      alias watch="tmux new-session -d -s watch-session 'bash ./bin/watch.sh'"
      alias unwatch='tmux kill-session -t watch-session'
      alias diff=difft
      alias ls='ls --color=auto'
      alias windows='systemctl reboot --boot-loader-entry=auto-windows'
    '';

    history = {
      path = "$HOME/.zsh_history";
      save = 100000;
      size = 100000;
      share = true;
      extended = true;
      ignoreSpace = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      ignorePatterns = [
        "pwd"
        "ls"
        "cd"
      ];
    };

    completionInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':vcs_info:git:*' formats '[%b]'
      autoload -Uz compinit colors vcs_info
      colors
      precmd() { vcs_info }
      compinit
    '';

    #    shellAliases = shellAliasesConfig.shellAliases.zsh;

    sessionVariables = {
      FLAKE = "$HOME/.dotfiles";
      LANG = "en_US.UTF-8";
      TERM = "xterm-256color";
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less -R";
      NODE_PATH = "$HOME/.npm-packages/lib/node_modules";
      DIRENV_LOG_FORMAT = "";
      READNULLCMD = "bat";
      BAT_THEME = "Solarized (dark)";
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
    };

    initExtra = ''
      # Zsh options
      setopt extendedglob nomatch
      setopt EXTENDED_HISTORY INC_APPEND_HISTORY HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
      unsetopt beep
      setopt PROMPT_SUBST

      # Key bindings
      bindkey -v
      bindkey '^R' history-incremental-search-backward
      export KEYTIMEOUT=1

      # Vi mode indicator
      vim_ins_mode="%{$fg[green]%}|%{$reset_color%}"
      vim_cmd_mode="%{$fg[red]%}|%{$reset_color%}"
      vim_mode=$vim_ins_mode

      function zle-keymap-select {
        vim_mode="''${''${KEYMAP/vicmd/$vim_cmd_mode}/(main|viins)/$vim_ins_mode}"
        zle reset-prompt
      }

      function zle-line-finish {
        vim_mode=$vim_ins_mode
      }

      zle -N zle-line-finish
      zle -N zle-keymap-select

      # Direnv hook
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

      # Utility functions
      function hashish() {
        local length=$1
        ${pkgs.openssl}/bin/openssl rand -base64 $(( length * 3 / 4 + 1 )) | tr -dc 'a-zA-Z0-9' | head -c $length
        echo
      }

      # FZF key bindings and completion
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      # Load NVM if installed
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Pyenv initialization
      if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)"
      fi

      # Source additional custom configurations
      [ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
    '';

    dirHashes = {
      dl = "$HOME/Downloads";
      nixconf = "$HOME/.config/nixos";
      dotfiles = "$HOME/.dotfiles";
      bins = "$HOME/bins";
      proj = "$HOME/Projects";
      repos = "$HOME/Repositories";
      docs = "$HOME/Documents";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
    ];
  };
}
