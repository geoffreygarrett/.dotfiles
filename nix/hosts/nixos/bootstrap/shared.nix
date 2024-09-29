{
  pkgs,
  keys,
  user,
  ...
}:
{
  # Basic system configuration
  system.stateVersion = "24.11";
  sdImage.compressImage = false;

  # Network configuration
  networking = {
    hostName = "bootstrap";
    networkmanager.enable = true;
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # User configuration (root only for bootstrap)
  users.users.root = {
    openssh.authorizedKeys.keys = keys;
  };

  programs.zsh.enable = true;

  # User configuration (normal user)
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = keys;
  };

  # Trusted public key for Nix
  nix.settings = {
    trusted-public-keys = [
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
  };

  # Enable basic system utilities
  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
