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

  #################
  # GNOME Settings
  #################

  gtk = {
    enable = true;
    theme = {
      name = "orchis-theme";
      package = pkgs.orchis-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme=1
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Roboto 12";
      document-font-name = "Roboto 12";
      monospace-font-name = "JetBrains Mono 10";
      cursor-blink = false;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "mendeley-reference-manager.desktop"
        "obsidian.desktop"
        "alacritty-neovim.desktop"
      ];
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

  #############
  # i3 Settings
  #############

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      fonts = {
        names = [
          "Roboto"
          "JetBrains Mono"
        ];
        size = 12.0;
      };
      terminal = "alacritty";
      modifier = "Mod4";
      # Add more i3 specific configurations here
    };
    extraConfig = ''
      # Set key repeat rate
      exec_always --no-startup-id xset r rate 225 25

      # Set GTK theme
      exec_always --no-startup-id gsettings set org.gnome.desktop.interface gtk-theme "orchis-theme"
      exec_always --no-startup-id gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
      exec_always --no-startup-id gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"

      # Set dark theme
      exec_always --no-startup-id gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    '';
  };

  ################
  # bspwm Settings
  ################

  xsession.windowManager.bspwm = {
    enable = true;
    settings = {
      border_width = 2;
      window_gap = 12;
      split_ratio = 0.52;
      borderless_monocle = true;
      gapless_monocle = true;
    };
    startupPrograms = [
      "xsetroot -cursor_name left_ptr"
      "xset r rate 225 25" # Set key repeat rate
      "gsettings set org.gnome.desktop.interface gtk-theme 'orchis-theme'"
      "gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'"
      "gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'"
      "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
    ];
  };

  # Sxhkd for bspwm keybindings
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Return" = "alacritty";
      "super + @space" = "rofi -show drun";
      "super + Escape" = "pkill -USR1 -x sxhkd";
      # Add more keybindings here
    };
  };

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
  # Uncomment and adjust the following block if you want to include Firefox
  # (mergeDesktopEntry "firefox" {
  #   name = "Firefox";
  #   genericName = "Web Browser";
  #   icon = "/path/to/your/new/firefox-icon.png";
  #   exec = "firefox %U";
  #   categories = [
  #     "Network"
  #     "WebBrowser"
  #   ];
  # })
  # ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };

    file = lib.mkMerge [
      linux-desktop-files
      {
        ".Xresources".text = ''
          Xft.dpi: 96
          Xft.antialias: true
          Xft.hinting: true
          Xft.rgba: rgb
          Xft.autohint: false
          Xft.hintstyle: hintslight
          Xft.lcdfilter: lcddefault

          ! Set key repeat rate
          Xkb.repeatDelay: 225
          Xkb.repeatInterval: 25
        '';

        ".xprofile".text = ''
          # Set key repeat rate
          xset r rate 225 25
        '';
      }
      # Uncomment the following line if you have additional files to import
      # (import ./files.nix { inherit user pkgs; })
    ];

    stateVersion = "24.05";
  };

}
