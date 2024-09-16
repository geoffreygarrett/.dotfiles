{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-Space"; # Uncomment to change prefix from default 'C-b'
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh"; # Uncomment and adjust if needed
    historyLimit = 5000;
    escapeTime = 0;
    # baseIndex = 1;  # Uncomment if you want windows/panes to start at 1
    # reverseSplit = true;  # Uncomment if needed
    extraConfig = ''
      # Set status bar colors
      set -g status-style bg=colour235,fg=colour136

      # Other custom configurations
      set-option -g history-limit 5000

      # vim-like pane resizing  
      bind -r C-k resize-pane -U
      bind -r C-j resize-pane -D
      bind -r C-h resize-pane -L
      bind -r C-l resize-pane -R

      # vim-like pane switching
      bind -r k select-pane -U 
      bind -r j select-pane -D 
      bind -r h select-pane -L 
      bind -r l select-pane -R 

      # and now unbind keys
      unbind Up     
      unbind Down   
      unbind Left   
      unbind Right  

      unbind C-Up   
      unbind C-Down 
      unbind C-Left 
      unbind C-Right

    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      # {
      #   plugin = continuum;
      #   extraConfig = ''
      #     set -g @continuum-restore 'on'
      #     set -g @continuum-save-interval '15'
      #   '';
      # }
    ];
  };

  # Include Tmux in the packages
  # home.packages = with pkgs; [
  #  tmux
  #];

  # Uncomment if you want to set a secure socket directory
  # home.sessionVariables.TMUX_TMPDIR = "$XDG_RUNTIME_DIR/tmux";
}
