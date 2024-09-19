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
}
