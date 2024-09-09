{
  config,
  pkgs,
  lib,
  home-manager,
  inputs,
  user,
  ...
}:
let
  shared-programs = import ../shared/home-manager/programs {
    inherit
      config
      pkgs
      lib
      home-manager
      inputs
      ;
  };
  secrets = import ./secrets.nix { inherit config pkgs user; };
in
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "tailscale-ui" ];
  };
  imports = [ secrets ];
  # TODO: Properly separate home config for system level config and home level.
  #  home.username = "${user}";
  #  home.homeDirectory = "/Users/${user}";
  programs = shared-programs // {
    gpg.enable = true;
  };
  home.packages = pkgs.callPackage ./packages.nix { inherit pkgs; };
  #  home.file."/Applications/Tailscale.app".source =
  #    "${pkgs.tailscale-ui}/Applications/Tailscale.app";

  #  # Fully declarative dock using the latest from Nix Store
  #  local = {
  #    dock.enable = true;
  #    dock.entries = [
  #      { path = "/Applications/Slack.app/"; }
  #      { path = "/System/Applications/Messages.app/"; }
  #      { path = "/System/Applications/Facetime.app/"; }
  #      { path = "/Applications/Telegram.app/"; }
  #      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
  #      { path = "/System/Applications/Music.app/"; }
  #      { path = "/System/Applications/News.app/"; }
  #      { path = "/System/Applications/Photos.app/"; }
  #      { path = "/System/Applications/Photo Booth.app/"; }
  #      { path = "/System/Applications/TV.app/"; }
  #      #      { path = "${pkgs.jetbrains.phpstorm}/Applications/PhpStorm.app/"; }
  #      { path = "/Applications/TablePlus.app/"; }
  #      { path = "/Applications/Asana.app/"; }
  #      { path = "/Applications/Drafts.app/"; }
  #      { path = "/System/Applications/Home.app/"; }
  ##      {
  ##        path = "${config.users.users.${user}.home}/.local/share/";
  ##        section = "others";
  ##        options = "--sort name --view grid --display folder";
  ##      }
  ##      {
  ##        path = "${config.users.users.${user}.home}/.local/share/downloads";
  ##        section = "others";
  ##        options = "--sort name --view grid --display stack";
  ##      }
  #    ];
  #  };

}

#  # It me
#  users.users.${user} = {
#    name = "${user}";
#    home = "/Users/${user}";
#    isHidden = false;
#    shell = pkgs.zsh;
#  };

#  homebrew = {
#    # This is a module from nix-darwin
#    # Homebrew is *installed* via the flake input nix-homebrew
#    enable = true;
#    casks = pkgs.callPackage ./casks.nix { };
#
#    # These app IDs are from using the mas CLI app
#    # mas = mac app store
#    # https://github.com/mas-cli/mas
#    #
#    # $ nix shell nixpkgs#mas
#    # $ mas search <app name>
#    #
#    masApps = {
#      "1password" = 1333542190;
#      "canva" = 897446215;
#      "drafts" = 1435957248;
#      "hidden-bar" = 1452453066;
#      "wireguard" = 1451685025;
#      "yoink" = 457622435;
#    };
#  };
#
#  imports = [
#    ./global
#    ./modules/darwin
#  ];
#  home.username = "geoffreygarrett";
#  home.homeDirectory = "/Users/geoffreygarrett";
#  sops.age.keyFile = "Users/geoffreygarrett/Library/Application Support/sops/age/keys.txt";
#
#  # [home.packages] ---|> [darwin/packages] ---|> [shared/packages]
#  home.packages = pkgs.callPackage ./packages.nix { };
#
#  #   # Fully declarative dock using the latest from Nix Store
#  #    local = {
#  #      dock.enable = true;
#  #      dock.entries = [
#  #        { path = "/Applications/Slack.app/"; }
#  #        { path = "/System/Applications/Messages.app/"; }
#  #        { path = "/System/Applications/Facetime.app/"; }
#  #        { path = "/Applications/Telegram.app/"; }
#  #        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
#  #        { path = "/System/Applications/Music.app/"; }
#  #        { path = "/System/Applications/News.app/"; }
#  #        { path = "/System/Applications/Photos.app/"; }
#  #        { path = "/System/Applications/Photo Booth.app/"; }
#  #        { path = "/System/Applications/TV.app/"; }
#  #        { path = "${pkgs.jetbrains.phpstorm}/Applications/PhpStorm.app/"; }
#  #        { path = "/Applications/TablePlus.app/"; }
#  #        { path = "/Applications/Asana.app/"; }
#  #        { path = "/Applications/Drafts.app/"; }
#  #        { path = "/System/Applications/Home.app/"; }
#  #        {
#  #          path = toString myEmacsLauncher;
#  #          section = "others";
#  #        }
#  #        {
#  #          path = "${config.users.users.${user}.home}/.local/share/";
#  #          section = "others";
#  #          options = "--sort name --view grid --display folder";
#  #        }
#  #        {
#  #          path = "${config.users.users.${user}.home}/.local/share/downloads";
#  #          section = "others";
#  #          options = "--sort name --view grid --display stack";
#  #        }
#  #      ];
#  #    };
#  # }
