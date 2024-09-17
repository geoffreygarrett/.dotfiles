{ config
, self
, pkgs
, lib
, home-manager
, inputs
, user
, ...
}:
let
in
{
  imports = [
    ../shared/aliases.nix
    ../shared/secrets.nix
    ../shared/home-manager/programs
  ];

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
    #      file = shared-files // import ./files.nix { inherit user pkgs; };
    stateVersion = "21.05";
  };
}
