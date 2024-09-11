{ pkgs, ... }:
with pkgs;
[
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  rust-analyzer
  sops
  fastfetch
  nixus

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
  tailscale
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

  # GUI Secuirty
  yubikey-manager

  # Encryption and security tools
  #  _1password
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Utility
  qrcp # Transfer files over wifi by scanning a QR code from your terminal
  qrtool # Generate QR codes from the command line

]
