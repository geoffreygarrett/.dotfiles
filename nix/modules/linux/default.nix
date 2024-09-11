{
  self,
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./home-manager.nix
    #    ./ssh.nix
  ];

  # Home Manager Standalone Configuration
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.05";
  #  home-manager.backupFileExtension = "nixus.bak";
  # Nixpkgs Configuration
  # nixpkgs.config = { };
  # nixpkgs.overlays = [ ];

  #  # Service Configuration
  #  services.ssh = {
  #    enable = true;
  #    port = 22;
  #    authorizedKeys = [
  #      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXHjv1eLnnOF31FhCTAC/7LG7hSyyILzx/+ZgbvFhl7"
  #    ];
  #    aliases = {
  #      sshd-start = "sshd-start";
  #      sshd-stop = "pkill sshd";
  #      sshd-restart = "sshd-stop && sshd-start";
  #      ssh-keygen = "ssh-keygen -t ed25519";
  #    };
  #  };

  #  # Home Manager Configuration
  #  home-manager = {
  #    backupFileExtension = "hm-bak";  # doesnt exist in base hm
  #    useGlobalPkgs = true; # doesnt exist in base hm
  #    useUserPackages = false; # doesnt exist in base hm
  #    specialArgs = {
  #      inherit (config) services;
  #      inherit self;
  #    };
  #    config = import ./home-manager.nix;
  #  };

  #  environment.packages = lib.mkIf (sops-config.secrets != { }) [
  #    pkgs.sops
  #    pkgs.age
  #    (pkgs.writeScriptBin "sops-nix-run" ''
  #      #!${pkgs.runtimeShell}
  #      echo "Running sops-nix manually..."
  #      ${builtins.toString script}
  #    '')
  #  ];

  # Build Configuration
  # build = {
  #   activation = { };
  #   activationBefore = { };
  #   activationAfter = { };
  # };
}
