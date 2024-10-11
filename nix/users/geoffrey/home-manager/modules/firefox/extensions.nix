{
  inputs,
  pkgs,
  ...
}:
with inputs.firefox-addons.packages.${pkgs.system};
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
