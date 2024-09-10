{
  self,
  inputs,
  config,
  lib,
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../modules/android
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
    substituters = (import ../../modules/shared/cachix { inherit pkgs lib; }).nix.settings.substituters;
    trustedPublicKeys =
      (import ../../modules/shared/cachix { inherit pkgs lib; }).nix.settings.trusted-public-keys;
  };

  # Environment Configuration
  environment = {
    packages = pkgs.callPackage ./packages.nix { inherit pkgs; };

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
      echo "Welcome to Nix-on-Droid!" | lolcat
      fortune | lolcat
    '';
  };

}
