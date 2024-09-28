{
  self,
  inputs,
  config,
  lib,
  pkgs,
  keys,
  user,
  ...
}:
let
  nixConfig = (import ../../modules/shared/cachix { inherit pkgs lib; }).nix.settings;
in
{
  imports = [
    ../../modules/android
  ];

  # User Configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # TODO: XREMAP!

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
    packages = pkgs.callPackage ./../../modules/android/packages.nix { inherit pkgs; };
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
      XDG_RUNTIME_DIR = "$HOME/.run";
      XDG_RUNTIME_DIR_FALLBACK = "$HOME/.run";
    };

    motd = ''
      Welcome to Celestial Blueprint's Nix-on-Droid!
      Celestial Blueprint: https://github.com/geoffreygarrett/celestial-blueprint
      Happy hacking!
    '';
  };

}
