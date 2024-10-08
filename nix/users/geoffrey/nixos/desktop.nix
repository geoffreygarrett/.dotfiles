{
  pkgs,
  ...
}:
{
  imports = [
    ./shared.nix
    ./modules/sway.nix
  ];
  home-manager = {
    users."geoffrey" = import ./home-manager/desktop.nix;
  };
  users.users.geoffrey.packages = with pkgs; [
    nautilus
    baobab
  ];
  services = {
    tumbler.enable = true;
  };
  fonts.packages = with pkgs; [
    dejavu_fonts
    emacs-all-the-icons-fonts
    feather-font # from overlay
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];
}
