{ pkgs, ... }:

[
  (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  pkgs.rust-analyzer
  pkgs.sops
  pkgs.fastfetch
  # SECRETS
  pkgs.age
  pkgs.micromamba
  pkgs.nixfmt-rfc-style
  # RUST-SCRIPT
  pkgs.cargo
  pkgs.rustc
  pkgs.libiconv
  pkgs.rust-script
  pkgs.pcsclite
  pkgs.gengetopt
  pkgs.opensc
  pkgs.pkg-config
  pkgs.wireguard-tools
  pkgs.tailscale
  pkgs.ripgrep # DEPENDANT: Telescope live_grep
  # DEVELOPMENT
  pkgs.lazygit
  # PENETRATION TESTING
  #  pkgs.aircrack-ng
  #  pkgs.airmon-ng
  #  pkgs.airodump-ng
  #  pkgs.aireplay-ng
  #  pkgs.aircrack-ng
  #  pkgs.nmap
  #  pkgs.metasploit
]
