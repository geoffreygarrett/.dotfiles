{
  config,
  self,
  pkgs,
  lib,
  home-manager,
  inputs,
  user,
  ...
}:
let
  linux-desktop-files = import ../linux/files.nix { inherit config user pkgs; };
in
{
  imports = [
    ../shared/aliases.nix
    ../shared/secrets.nix
    ../shared/home-manager/programs
  ];
  # TODO: Decide whether we want this system-wide or only user-specific later.

  # # Ensure the custom icon is copied to the proper location
  # environment.etc."icons/alacritty-neovim.png".source = ../shared/assets/alacritty/flat/alacritty_flat_512.png;

  # # Define the .desktop file for opening with Alacritty and Neovim
  # environment.etc."xdg/applications/alacritty-neovim.desktop".text = ''
  #   [Desktop Entry]
  #   Version=1.0
  #   Name=Alacritty with Neovim
  #   Comment=Open files with Neovim inside Alacritty
  #   Exec=${pkgs.alacritty}/bin/alacritty -e ${pkgs.neovim}/bin/nvim %F
  #   Terminal=false
  #   Type=Application
  #   MimeType=text/plain;application/x-shellscript;
  #   Icon=/etc/icons/alacritty-neovim.png
  #   Categories=Utility;TextEditor;
  # '';
  # TODO: Figure out how to define user-level xdg mime apps. 
  # Associate file types with the Alacritty + Neovim desktop entry

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "text/plain" = [ "alacritty-neovim.desktop" ];
      "application/x-shellscript" = [ "alacritty-neovim.desktop" ];
    };
    defaultApplications = {
      "text/plain" = [ "alacritty-neovim.desktop" ];
      "application/x-shellscript" = [ "alacritty-neovim.desktop" ];
    };
  };
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "mendeley-reference-manager.desktop"
        "obsidian.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      font-name = "Roboto 12";
      document-font-name = "Roboto 12";
      monospace-font-name = "JetBrains Mono 10";
      cursor-blink = false;
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      repeat-interval = lib.hm.gvariant.mkUint32 25;
      delay = lib.hm.gvariant.mkUint32 225;
      repeat = true;
    };
    "org/gnome/desktop/search-providers" = {
      disabled = [
        "org.gnome.Contacts.desktop"
        "org.gnome.Documents.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      sort-order = [
        "org.gnome.Settings.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Calendar.desktop"
      ];
    };
    "org/gnome/shell/app-grid" = {
      columns-count = 8;
      rows-count = 4;
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
    "org/gnome/shell/window-switcher" = {
      app-icon-mode = "both";
      current-workspace-only = false;
    };
  };
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = linux-desktop-files; # // import ./files.nix { inherit user pkgs; };
    stateVersion = "24.05";
  };
}
