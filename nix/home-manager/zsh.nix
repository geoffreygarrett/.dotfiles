{ pkgs, config, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    history = {
      path = "$HOME/.zsh_history";
      save = 100000;
      size = 100000;
      share = true;
      extended = true;
      ignoreSpace = true;
      ignoreDups = true;
    };

    completionInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':vcs_info:git:*' formats '[%b]'
      autoload -Uz compinit
      autoload -U colors && colors
      autoload -Uz vcs_info
      precmd() { vcs_info }
      compinit
    '';

    shellAliases = {
      ls = "exa --icons --group-directories-first";
      ll = "exa -alF --icons --group-directories-first";
      l = "exa -a --icons --group-directories-first";
      tree = "exa --tree --icons";
      cat = "bat --style=plain --paging=never";
      less = "bat";
      grep = "rg";
      find = "fd";
      top = "htop";
      df = "duf";
      du = "ncdu";
      ping = "prettyping";
      watch = "viddy";
      sudoe = "sudo -E -s";
      tb = "nc termbin.com 9999";
      pingt = "ping -c 5 google.com";
      pingd = "ping -c 5 8.8.8.8";
      gitlog = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
      gitlines = "git ls-files | xargs wc -l";
      dirsize = "du -sh $PWD/*";
      nixbuild = "sudo nixos-rebuild switch --flake \"/home/senoraraton/bins/nixosconf/#\"";
      n = "nvim";
      k = "kubectl";
      pc = "podman-compose";
      kpods = "kubectl get pods --all-namespaces | grep -v 'kube-system'";
      kbox = "kubectl run temp-pod --rm -i --tty --image=busybox -- /bin/sh";
    };

    sessionVariables = {
      LANG = "en_US.UTF-8";
      TERM = "xterm-256color";
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less -R";
      PATH = "$HOME/.local/bin:$HOME/.npm-packages/bin:$PATH";
      NODE_PATH = "$HOME/.npm-packages/lib/node_modules";
      RPROMPT = "%F{57}\${vcs_info_msg_0_}%f%b";
      DIRENV_LOG_FORMAT = "";
      READNULLCMD = "bat";
      BAT_THEME = "Solarized (dark)";
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
    };

    initExtra = ''
      # Source the content from config.zsh.configContent
      ${config.zsh.rc}

      # General options
      setopt extendedglob nomatch
      setopt EXTENDED_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      unsetopt beep
      bindkey -v
      bindkey '^R' history-incremental-search-backward
      REPORTTIME=20
      setopt +o nomatch
      setopt PROMPT_SUBST
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

      # Prompt
      PS1='%T%F{33}|%n%{$reset_color%}@%F{13}%m|%f%{$fg[green]%}%~%{$reset_color%}%{$fg[white]%}''${vim_mode}%'

      # Welcome message
      echo -e "\e[1;35m$(${pkgs.figlet}/bin/figlet -f eftirobot 'H. & G.')\e[0m"

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
      if [ -f $HOME/.zshrc.local ]; then
        source $HOME/.zshrc.local
      fi
    '';

    dirHashes = {
      dl = "$HOME/Downloads";
      nixconf = "$HOME/.config/nixos";
      bins = "$HOME/bins";
      proj = "$HOME/Projects";
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