# NixOS system-level configuration
# File: /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  username = "geoffrey";
in

{
  # Enable OpenGL
  hardware.opengl.enable = true;

  # Enable sound
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Enable XDG portal for screen sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Enable polkit for authentication
  security.polkit.enable = true;

  # Install some basic packages
  environment.systemPackages = with pkgs; [
    wayland
    grim # screenshot utility
    slurp # region selection tool
    wl-clipboard # clipboard utility
    mako # notification daemon
  ];

  # Add user to necessary groups
  users.users.${username}.extraGroups = [
    "video"
    "audio"
  ];
  # }
}
