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
  mergeDesktopEntry =
    name: newConfig:
    lib.mkMerge [
      (lib.mkIf (config.xdg.desktopEntries ? ${name}) {
        ${name} = lib.recursiveUpdate config.xdg.desktopEntries.${name} newConfig;
      })
      (lib.mkIf (!config.xdg.desktopEntries ? ${name}) {
        ${name} = newConfig;
      })
    ];
in
{
  imports = [
    ../shared/aliases.nix
    ../shared/home-manager/programs
  ];

  # xdg.desktopEntries = lib.mkMerge [
  #   (mergeDesktopEntry "alacritty" {
  #     name = "Alacritty";
  #     genericName = "Terminal";
  #     icon = ../shared/assets/alacritty/smooth/alacritty_smooth_512.png;
  #     exec = "alacritty";
  #     terminal = false;
  #     categories = [
  #       "System"
  #       "TerminalEmulator"
  #     ];
  #   })
  #   (mergeDesktopEntry "nvim" {
  #     name = "Neovim";
  #     genericName = "Terminal with Neovim";
  #     icon = ../shared/assets/neovim/neovim_512x512x32.png;
  #     exec = "alacritty -e nvim";
  #     terminal = false;
  #     categories = [
  #       "System"
  #       "TerminalEmulator"
  #     ];
  #     associations = [
  #       "text/english"
  #       "text/plain"
  #       "text/x-makefile"
  #       "text/x-c++hdr"
  #       "text/x-c++src"
  #       "text/x-chdr"
  #       "text/x-csrc"
  #       "text/x-java"
  #       "text/x-moc"
  #       "text/x-pascal"
  #       "text/x-tcl"
  #       "text/x-tex"
  #       "application/x-shellscript"
  #       "text/x-c"
  #       "text/x-c++"
  #     ];
  #   })
  #   # Uncomment and adjust the following block if you want to include Firefox
  #   # (mergeDesktopEntry "firefox" {
  #   #   name = "Firefox";
  #   #   genericName = "Web Browser";
  #   #   icon = "/path/to/your/new/firefox-icon.png";
  #   #   exec = "firefox %U";
  #   #   categories = [
  #   #     "Network"
  #   #     "WebBrowser"
  #   #   ];
  #   # })
  # ];

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
        "alacritty-neovim.desktop"
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
