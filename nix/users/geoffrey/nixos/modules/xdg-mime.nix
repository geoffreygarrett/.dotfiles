{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    feh
    inkscape
    gimp
    xdg-utils # For xdg-mime
    shared-mime-info # For mime database
    (makeDesktopItem {
      name = "feh";
      exec = "feh %F";
      comment = "Image viewer";
      desktopName = "Feh";
      genericName = "Image viewer";
      mimeTypes = [
        "image/png"
        "image/jpeg"
        "image/gif"
      ];
      categories = [
        "Graphics"
        "Viewer"
      ];
    })
  ];

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/png" = "feh.desktop";
      "image/jpeg" = "feh.desktop";
      "image/gif" = "feh.desktop";
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
    };
    addedAssociations = {
      "image/png" = [
        "feh.desktop"
        "gimp.desktop"
        "org.inkscape.Inkscape.desktop"
      ];
      "image/jpeg" = [
        "feh.desktop"
        "gimp.desktop"
      ];
      "image/gif" = [
        "feh.desktop"
        "gimp.desktop"
      ];
      "image/svg+xml" = [
        "org.inkscape.Inkscape.desktop"
        "gimp.desktop"
        "feh.desktop"
      ];
    };
  };

  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/run/current-system/sw/share"
      "$HOME/.nix-profile/share"
      "$HOME/.share"
    ];
  };
}
