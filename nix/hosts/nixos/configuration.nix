{ config, pkgs, ... }:

let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Uy9fE/YF8/puhUOwOcHKqDzDW75zt9DndypPEhQaG nix-on-droid@localhost"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITvBraRmM6IvQFt8VUHRx9hZ5DZVkPX3ORlfVqGa05z"
  ];
  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };

in
{
  imports = [
    ./hardware-configuration.nix
    ./config/base.nix
    ./config/networking.nix
    ./config/users.nix
    ./config/desktop.nix
    ./config/services.nix
  ];

  # System-wide configurations
  system.stateVersion = "24.05";
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # User-specific configuration
  users.users.geoffrey = {
    isNormalUser = true;
    description = "Geoffrey Garrett";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "kvm"
      "tailscale"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = keys;
  };
  users.users.root.openssh.authorizedKeys.keys = keys;

  # Uncomment to allow unfree packages
  # nixpkgs.config.allowUnfree = true;
}
