{
  self,
  inputs,
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  nixConfig = (import ../../modules/shared/cachix { inherit pkgs lib; }).nix.settings;
in
{
  imports = [
    "${self}/nix/modules/android"
  ];

  # User Configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Nix Configuration
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # package = pkgs.nix;
    # nixPath = [ ];
    # registry = { };
    substituters = nixConfig.substituters;
    trustedPublicKeys = nixConfig.trusted-public-keys;
  };

  # Environment Configuration
  environment = {
    packages = pkgs.callPackage "${self}/nix/modules/android/packages.nix" { inherit pkgs; };
    etcBackupExtension = ".bak";

    # etc = {
    #   "example-configuration-file" = {
    #     source = "/nix/store/.../etc/dir/file.conf.example";
    #   };
    #   "default/useradd".text = "GROUP=100 ...";
    # };

    sessionVariables = {
      EDITOR = "nvim";
      LANG = "en_US.UTF-8";
      PATH = "$HOME/.local/bin:$PATH";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
    };

    motd = ''
      ${"\x1b"}[1;36mWelcome to Nix-on-Droid!${"\x1b"}[0m
      ${"\x1b"}[0;32mCelestial Blueprint: ${"\x1b"}[0;34mhttps://github.com/geoffreygarrett/celestial-blueprint${"\x1b"}[0m
      ${"\x1b"}[0;35mHappy hacking!${"\x1b"}[0m
    '';
  };

}
