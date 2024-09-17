{ pkgs, ... }:
with pkgs;
[
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

  fastfetch
  nixus

  # RUST-SCRIPT
  #  libiconv
  rustup
  rust-script
  pcsclite
  gengetopt
  opensc
  pkg-config
  wireguard-tools
  ripgrep # DEPENDANT: Telescope live_grep

  # DEVELOPMENT
  lazygit
  micromamba
  zig # also needed for cc compiler for lazy in neovim
  git
  difftastic
  jq
  mdt
  #  gptcommit

  # Security
  gnupg
  openssh

  # Encryption and security tools
  #  _1password
  age
  sops
  age-plugin-yubikey
  gnupg
  libfido2
  ssh-to-age
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
