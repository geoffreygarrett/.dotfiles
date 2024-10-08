{
  config,
  pkgs,
  ...
}:
let
  username = "geoffrey";
  description = "Geoffrey Garrett";
in
{
  sops.secrets."users/${username}/password" = {
    neededForUsers = true;
  };
  home-manager.backupFileExtension = ".bak";
  users.mutableUsers = false;
  users.users.geoffrey = {
    inherit description;
    name = "${username}";
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      # "docker"
      # "video"
      # "audio"
      # "input"
      # "disk"
    ];
    hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = import ../authorized-keys.nix;
    packages = with pkgs; [
      git
    ];
  };
  services.gvfs.enable = true;
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    inetutils
  ];
}
