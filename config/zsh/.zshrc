HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt autocd extendedglob nomatch appendhistory
unsetopt beep
bindkey -v
REPORTTIME=20
setopt +o nomatch

zstyle :compinstall filename '/home/senoraraton/.zshrc'
zstyle ':vcs_info:git:*' formats '[%b]'
autoload -Uz compinit
autoload -U colors && colors
autoload -Uz vcs_info
precmd() {vcs_info}
compinit

#Aliases

alias ls='ls -h --color=auto --group-directories-first'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF --color=auto'
alias less='less -R'
alias watch='watch --color'
#alias sudoe='sudo -E -s'
#alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias tb="nc termbin.com 9999"
alias pingtest="ping -c 5 google.com"
alias pingdns="dig 8.8.8.8 & ping -c 5 8.8.8.8"
alias gitlog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"
alias gitlines="git ls-files | xargs wc -l"
alias dirsize='du -sh $PWD/*'
alias aucompile='arduino-cli compile --fqbn arduino:avr:uno $1'
alias audeploy='arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno $1'
alias aumonitor='arduino-cli monitor -p /dev/ttyACM0'
alias nixconf='sudo -E -s nvim ~/.config/nixos'
alias nixbuild='sudo nixos-rebuild switch --flake "/home/senoraraton/.config/nixos#senoraraton"'
alias anynixsh='any-nix-shell zsh --info-right | source /dev/stdin'
alias n="nvim"
alias k="kubectl"
alias pc="podman-compose"
alias kpods="kubectl get pods --all-namespaces | grep -v 'kube-system'"
alias kbox="kubectl run temp-pod --rm -i --tty --image=busybox -- /bin/sh"
alias dkip="docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
alias dkpsl='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Status}}" | lolcat -t -S 6498 -p 2'
alias dkps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Status}}" | awk '\''
  NR==1 {
    printf "\033[0;32m%-12s\033[0m ", "ID"
    printf "%-31s", "Name"
    printf "%-25s", "State"
    printf "%-10s\n", "Status"
  }
  NR>1 {
    printf "\033[0;32m%-12s\033[0m ", $1
    printf "\033[1;35m%-31s\033[0m", $2
    printf "\033[1;34m%-25s\033[0m", $3
    printf "\033[1;33m%-10s\033[0m\n", $4
  }
'\'''
alias click="echo GRANT_ENTRY_ACCESS | nc -u 10.21.1.113 3339"

#Prompt

setopt PROMPT_SUBST
export KEYTIMEOUT=1

PS1='%T%F{33}|%n%{$reset_color%}@%F{13}%m|%f%{$fg[green]%}%~%{$reset_color%}%{$fg[white]%}${vim_mode}%'
RPROMPT='%F{57}${vcs_info_msg_0_}%f%b'

#Config vim indicator -----------------------
vim_ins_mode="%{$fg[green]%}|%{$reset_color%}"
vim_cmd_mode="%{$fg[red]%}|%{$reset_color%}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  zle reset-prompt
}

function zle-line-finish {
  vim_mode=$vim_ins_mode
}

zle -N zle-line-finish
zle -N zle-keymap-select
#End Config vim indicator -------------------

#Env Vars
export LANG=en_US.UTF-8
export TERM=kitty
export EDITOR=nvim
export LUA_PATH=/home/senoraraton/.config/nvim/lua/senoraraton/?.lua

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=~/.npm-packages/bin:$PATH
export NODE_PATH=~/.npm-packages/lib/node_modules

echo -e "\e[1;35m$(figlet 'Hack the Planet')\e[0m"
