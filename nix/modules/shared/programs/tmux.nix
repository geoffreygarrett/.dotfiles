{ pkgs, ... }:
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
  tmux-browser = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-browser";
    version = "unstable-2022-10-24";
    src = pkgs.fetchFromGitHub {
      owner = "ofirgall";
      repo = "tmux-browser";
      rev = "c3e115f9ebc5ec6646d563abccc6cf89a0feadb8";
      sha256 = "sha256-ngYZDzXjm4Ne0yO6pI+C2uGO/zFDptdcpkL847P+HCI=";
    };
  };

in
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    package = pkgs.tmux;
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
      set -g status-style bg=default,fg=default

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

      # Custom scripts
      bind-key -r f run-shell "tmux neww ${pkgs.tmux-sessionizer}/bin/tms"

      # tmux-sessionizer [tms]
      bind-key T display-popup -E "tms"         # tms fuzzy find repos
      bind-key S display-popup -E "tms switch"  # tms switch between active sessions
      bind-key W display-popup -E "tms windows" # tms show active windows in current session
      bind-key R command-prompt -p "Rename session to: " "run-shell 'tms rename %1'"  # Rename session
      bind-key F run-shell 'tms refresh'        # Refresh session (create missing worktree windows)
      bind-key K run-shell 'tms kill'           # Kill session and switch to another
      bind-key ( switch-client -p\; refresh-client -S  # Switch to previous session and refresh
      bind-key ) switch-client -n\; refresh-client -S  # Switch to next session and refresh
      set -ag status-right "#(tms sessions)"  # Show sessions in status bar

      # custom
      # floating terminal
      bind-key Enter display-popup -E "tmux neww -n floating -c '#{pane_current_path}' 'zsh -i'"

      # TODO.md, complements of ThePrimeagen
      # https://github.com/ThePrimeagen/.dotfiles/blob/602019e902634188ab06ea31251c01c1a43d1621/tmux/.tmux.conf#L24
      bind -r D neww -c "#{pane_current_path}" "[[ -e TODO.md ]] && nvim TODO.md || nvim ~/.dotfiles/personal/todo.md"
    '';
    plugins = with pkgs; [
      tmux-mem-cpu-load
      {
        plugin = tmux-pomodoro-plus;
        extraConfig = ''
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
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all 'sed -i -E "s|(pane.[^:]+:)[^;]+;.*[[:space:]]([^[:space:]]+)$|\1nvim \2|" "$resurrect_dir/last"'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-processes '"~nvim"'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '5'
        '';
      }
      # {
      #   plugin = tmux-browser;
      #   extraConfig = ''
      #     set -g @browser_close_on_deattach '1'
      #   '';
      # }
    ];
  };
  home.packages = with pkgs; [
    tmux
  ];
}
