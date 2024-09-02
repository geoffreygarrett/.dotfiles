{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    #language=sh
    initExtraBeforeCompInit = ''
      # Spaceship prompt configuration
      SPACESHIP_PROMPT_ORDER=(
        user
        host
        dir
        git
        node
        rust
        python
        golang
        docker
        aws
        venv
        conda
        exec_time
        line_sep
        battery
        vi_mode
        jobs
        exit_code
        char
      )
      SPACESHIP_PROMPT_ADD_NEWLINE=false
      SPACESHIP_CHAR_SYMBOL="❯"
      SPACESHIP_CHAR_SUFFIX=" "
      SPACESHIP_USER_SHOW=always
      SPACESHIP_HOST_SHOW=always
      SPACESHIP_DIR_TRUNC=0
      SPACESHIP_GIT_SYMBOL=""
      SPACESHIP_GIT_BRANCH_COLOR="yellow"
      SPACESHIP_GIT_STATUS_COLOR="red"
      SPACESHIP_PACKAGE_SYMBOL="📦 "
      SPACESHIP_NODE_SYMBOL="⬢ "
      SPACESHIP_RUBY_SYMBOL="💎 "
      SPACESHIP_PYTHON_SYMBOL="🐍 "
      SPACESHIP_DOCKER_SYMBOL="🐳 "
      SPACESHIP_AWS_SYMBOL="☁️ "
    '';
  };
}