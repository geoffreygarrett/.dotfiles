{ inputs, ... }:
with inputs.firefox-addons.packages."x86_64-linux";
[
  bitwarden
  ublock-origin
  sponsorblock
  darkreader
  tridactyl
  metamask
  sidebery
  youtube-shorts-block
]
