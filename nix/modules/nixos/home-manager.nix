{
  config,
  pkgs,
  user,
  ...
}:
let
  linux-desktop-files = import ../linux/files.nix { inherit config user pkgs; };
in
{
  imports = [
    ../shared/aliases.nix
    ../shared/programs
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
  xsession.initExtra = ''
    ${pkgs.xorg.xset}/bin/xset r rate 200 45
  '';
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { };

    # file = lib.mkMerge [
    #   linux-desktop-files
    #   {
    #     ".Xresources".text = ''
    #       Xft.dpi: 96
    #       Xft.antialias: true
    #       Xft.hinting: true
    #       Xft.rgba: rgb
    #       Xft.autohint: false
    #       Xft.hintstyle: hintslight
    #       Xft.lcdfilter: lcddefault
    #
    #       ! Set key repeat rate
    #       Xkb.repeatDelay: 225
    #       Xkb.repeatInterval: 25
    #     '';
    #
    #     ".xprofile".text = ''
    #       # Set key repeat rate
    #       xset r rate 225 25
    #     '';
    #   }
    #   # Uncomment the following line if you have additional files to import
    #   # (import ./files.nix { inherit user pkgs; })
    # ];
    #
    stateVersion = "24.05";
  };

}
