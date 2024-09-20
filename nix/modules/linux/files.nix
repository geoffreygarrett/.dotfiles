{
  config,
  user,
  pkgs,
  ...
}:
let
  icon-files = import ../shared/files/icons.nix { inherit user pkgs; };
in
icon-files
// {

  #$  ".config/gtk-4.0/settings.ini".text = ''
  #$    [Settings]
  #$    gtk-application-prefer-dark-theme=1
  #$  '';
  # "${config.home.profileDirectory}/share/applications/alacritty-neovim.desktop" = {
  #   text = ''
  #     [Desktop Entry]
  #     Version=1.0
  #     Name=Alacritty with Neovim
  #     Comment=Open files with Neovim inside Alacritty
  #     Exec=${pkgs.alacritty}/bin/alacritty -e nvim %F
  #     Terminal=false
  #     Type=Application
  #     MimeType=text/plain;application/x-shellscript;
  #     Icon=local/share/icons/alacritty_flat_512.png
  #     Categories=Utility;TextEditor;
  #   '';
  # };
  #
  # TODO: Add some build-time gurantee as to whether the directory exists here. 
  # Ideally I start using impermanence later down the line.
  ".config/tms/config.toml".text = ''
    # General settings
    default_session = "main"
    display_full_path = true
    search_submodules = true
    recursive_submodules = false
    switch_filter_unknown = true
    session_sort_order = "LastAttached"

    # Excluded directories
    excluded_dirs = [
        ".git",
        "node_modules",
        "target",
        "build",
    ]

    # Search directories: [path, depth]
    search_dirs = [
        ["${config.home.homeDirectory}", 1],
        ["${config.home.homeDirectory}/Projects", 1],
    ]

    # Picker colors (adapted for Deep Ocean theme)
    [picker_colors]
    highlight_color = "#1F2233"        # Highlight color
    highlight_text_color = "#eeffff"   # White/Black Color for contrast
    border_color = "#0F111A"           # Border color
    info_color = "#717CB4"             # Gray Color for info text
    prompt_color = "#84ffff"           # Accent Color for prompt
  '';
}
