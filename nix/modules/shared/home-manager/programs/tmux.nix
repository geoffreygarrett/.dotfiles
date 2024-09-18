#{ config, pkgs, ... }:
#{
#  programs.tmux = {
#    enable = true;
#    prefix = "C-Space";
#    keyMode = "vi";
#    mouse = true;
#    shell = "${pkgs.zsh}/bin/zsh";
#    historyLimit = 5000;
#    escapeTime = 0;
#    extraConfig = ''
#      set -g default-terminal "screen-256color"
#      set -as terminal-overrides ",xterm-256color:RGB"
#    '';
#  };
#}

{ config, pkgs, ... }:
let
  tmux-mem-cpu-load = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-mem-cpu-load";
    version = "3.8.1";
    src = pkgs.fetchFromGitHub {
      owner = "thewtex";
      repo = "tmux-mem-cpu-load";
      rev = "v3.8.1";
      sha256 = "0k3kgxw7gd3z25cw8av4b1mkn50fxmql8lyzban39p14p08iq1gi";
    };
  };
  tmux-pomodoro-plus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-pomodoro-plus";
    version = "1.0.2";
    src = pkgs.fetchFromGitHub {
      owner = "olimorris";
      repo = "tmux-pomodoro-plus";
      rev = "v1.0.2";
      sha256 = "sha256-QsA4i5QYOanYW33eMIuCtud9WD97ys4zQUT/RNUmGes=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 5000;
    escapeTime = 0;
    extraConfig = ''
      # Terminal settings
      # NOTE: Ensures no colour clash with Alacritty.
      set -g default-terminal "screen-256color"
      set -as terminal-overrides ",xterm-256color:RGB"

      # Colors
      # set -g status-style bg=#0F111A,fg=#8F93A2
      set -g status-style bg=default,fg=default
      # set -g pane-border-style fg=#191A21
      # set -g pane-active-border-style fg=#84ffff
      # set -g message-style bg=#0F111A,fg=#f07178
      # set -g mode-style "fg=#0F111A,bg=#84ffff"
      # set -ga terminal-overrides ",xterm-256color:Tc"

      # Set background color with 85% opacity
      #set -g window-style "bg=#0F111AD9"
      #set -g window-active-style "bg=#0F111AD9"
      #set -g window-style "bg=default"
      #set -g window-active-style "bg=default"

      # Status bar
      set -g status-interval 2
      set -g status-position top
      set -g status-justify centre
      set -g status-left-length 50
      set -g status-right-length 100

      # Left status
      set -g status-left "#[fg=#0F111A bg=#82aaff bold] #S #[fg=#82aaff bg=#0F111A]"
      set -ag status-left "#{?client_prefix,#[fg=#0F111A bg=#c792ea] PREFIX #[fg=#c792ea bg=#0F111A],#[fg=#0F111A bg=#0F111A]}"

      # Window status
      set-window-option -g window-status-format " #I #W "
      set-window-option -g window-status-current-format "#[fg=#f78c6c,bg=#1A1C25,bold] #I #W "

      # Right status
      set -g status-right "#{pomodoro_status}"
      set -ag status-right "#[fg=#0F111A,bg=#c3e88d]#($HOME/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load --colors --powerline-right --interval 2)"
      set -ag status-right "#[fg=#0F111A,bg=#c792ea,bold] %H:%M "

      # Pane management
      bind -r C-k resize-pane -U 5
      bind -r C-j resize-pane -D 5
      bind -r C-h resize-pane -L 5
      bind -r C-l resize-pane -R 5
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Unbind arrow keys
      unbind Up
      unbind Down
      unbind Left
      unbind Right

      # Pomodoro settings
      set -g @pomodoro_toggle 'C-p'
      set -g @pomodoro_cancel 'P'
      set -g @pomodoro_skip '_'
      set -g @pomodoro_mins 25
      set -g @pomodoro_break_mins 5
      set -g @pomodoro_intervals 4
      set -g @pomodoro_long_break_mins 25
      set -g @pomodoro_repeat 'off'
      set -g @pomodoro_disable_breaks 'off'
      set -g @pomodoro_on " 🍅"
      set -g @pomodoro_complete " ✔︎"
      set -g @pomodoro_pause " ⏸︎"
      set -g @pomodoro_prompt_break " ⏲︎ break?"
      set -g @pomodoro_prompt_pomodoro " ⏱︎ start?"
      set -g @pomodoro_menu_position "R"
      set -g @pomodoro_sound 'off'
      set -g @pomodoro_notifications 'off'
      set -g @pomodoro_granularity 'on'
      set -g @pomodoro_interval_display "[%s/%s]"
    '';
    plugins = with pkgs.tmuxPlugins; [
      tmux-mem-cpu-load
      tmux-pomodoro-plus
      continuum
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
    ];
  };
  home.packages = with pkgs; [
    tmux
  ];
}

#{ config, pkgs, ... }:
#
#let
#  # Thanks: https://github.com/DanielFGray/dotfiles/blob/master/tmux.remote.conf
#  remoteConf = builtins.toFile "tmux.remote.conf" ''
#    unbind C-q
#    unbind q
#    set-option -g prefix C-s
#    bind s send-prefix
#    bind C-s last-window
#    set-option -g status-position top
#  '';
#in
#{
#
#  imports = [ ./theme.nix ];
#
#  programs.tmux = {
#    enable = true;
#    shortcut = "q";
#    escapeTime = 10;
#    keyMode = "vi";
#    terminal = "tmux-256color";
#    historyLimit = 50000;
#
#    extraConfig =
#      with config.theme;
#      with pkgs.tmuxPlugins;
#      ''
#        # Plugins
#        run-shell '${copycat}/share/tmux-plugins/copycat/copycat.tmux'
#        run-shell '${sensible}/share/tmux-plugins/sensible/sensible.tmux'
#        run-shell '${urlview}/share/tmux-plugins/urlview/urlview.tmux'
#
#        bind-key R run-shell ' \
#          tmux source-file /etc/tmux.conf > /dev/null; \
#          tmux display-message "sourced /etc/tmux.conf"'
#
#        if -F "$SSH_CONNECTION" "source-file '${remoteConf}'"
#
#        set-option -g status-right ' #{prefix_highlight} "#{=21:pane_title}" %H:%M %d-%b-%y'
#        set-option -g status-left-length 20
#        set-option -g @prefix_highlight_fg '${colors.background}'
#        set-option -g @prefix_highlight_bg '${colors.dominant}'
#        run-shell '${prefix-highlight}/share/tmux-plugins/prefix-highlight/prefix_highlight.tmux'
#
#        # Be faster switching windows
#        bind C-n next-window
#        bind C-p previous-window
#
#        # Send the bracketed paste mode when pasting
#        bind ] paste-buffer -p
#
#        set-option -g set-titles on
#
#        bind C-y run-shell ' \
#          ${pkgs.tmux}/bin/tmux show-buffer > /dev/null 2>&1 \
#          && ${pkgs.tmux}/bin/tmux show-buffer | ${pkgs.xsel}/bin/xsel -ib'
#
#        # Force true colors
#        set-option -ga terminal-overrides ",*:Tc"
#
#        set-option -g mouse on
#        set-option -g focus-events on
#
#        # Stay in same directory when split
#        bind % split-window -h -c "#{pane_current_path}"
#        bind '"' split-window -v -c "#{pane_current_path}"
#
#        # Colorscheme
#        set-option -g status-style 'fg=${colors.dimForeground}, bg=${colors.background}'
#
#        set-option -g window-status-current-style 'fg=${colors.dominant}'
#
#        set-option -g pane-border-style 'fg=${colors.background}'
#        set-option -g pane-active-border-style 'fg=${colors.dominant}'
#
#        set-option -g message-style 'fg=${colors.background}, bg=${colors.dimForeground}'
#
#        set-option -g mode-style    'fg=${colors.background}, bg=${colors.dominant}'
#
#        set-option -g display-panes-active-colour '${colors.dominant}'
#        set-option -g display-panes-colour '${colors.dimForeground}'
#
#        set-option -g clock-mode-colour '${colors.dominant}'
#      '';
#  };
#}
