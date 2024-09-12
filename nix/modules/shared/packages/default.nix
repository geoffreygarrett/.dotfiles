{ pkgs, ... }:
with pkgs;
[
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  rust-analyzer
  sops
  fastfetch
  nixus

  syncthing

  # SECRETS
  age

  # RUST-SCRIPT
  cargo
  rustc
  libiconv
  rust-script
  pcsclite
  gengetopt
  opensc
  pkg-config
  wireguard-tools
  tailscale # (Reqires root, breaks NixOnDroid), no access to netif's.
  ripgrep # DEPENDANT: Telescope live_grep

  # DEVELOPMENT
  lazygit
  micromamba
  zig # also needed for cc compiler for lazy in neovim
  difftastic
  jq

  # Security
  gnupg
  openssh

  # Encryption and security tools
  #  _1password
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Nix
  #home-manager

  # CC essential
  #      cc-essential = mkPackageSet [
  #        gcc  # or clang, depending on your preference
  #        binutils  # Provides essential tools like 'ld' (linker)
  #        gnumake  # Common build tool, often needed alongside gcc
  #      ];

  gcc

  # Utility
  qrcp # Transfer files over wifi by scanning a QR code from your terminal (Reqires root, breaks NixOnDroid)
  qrtool # Generate QR codes from the command line

]
