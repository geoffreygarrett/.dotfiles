{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.desktopEnvironment.gnome;
  screens = [
    {
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
    }
    {
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
    }
  ];
in
{
  options.desktopEnvironment.gnome = {
    enable = mkEnableOption "GNOME desktop environment";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        sessionCommands = ''
          ${builtins.concatStringsSep "\n" (
            builtins.map (
              s:
              "${pkgs.xorg.xrandr}/bin/xrandr --output ${s.output} --mode ${s.mode} --rate ${s.rate} ${
                if s.primary then "--primary" else ""
              }"
            ) screens
          )}
          ${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}
        '';
      };
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface]
          color-scheme='prefer-dark'
          gtk-theme='Adwaita-dark'

          [org.gnome.desktop.background]
          picture-uri='file:///etc/login-wallpaper.png'
          picture-uri-dark='file:///etc/login-wallpaper.png'
          picture-options='spanned'
          primary-color='#000000'
        '';
      };
    };

    environment.systemPackages = with pkgs; [
      firefox
      wl-clipboard
    ];

    # Force Gtk applications to use dark theme
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };

    # Set dark theme for Qt applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    #################                                   };
    # GNOME Settings                                  }
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
  };
}
