{
  config,
  user,
  self,
  pkgs,
  inputs,
  ...
}:
let
  yaml2json = pkgs.writeShellScriptBin "yaml2json" ''
    ${pkgs.remarshal}/bin/remarshal -if yaml -of json "$1"
  '';

  yamlContent = builtins.fromJSON (
    builtins.readFile (
      pkgs.runCommand "ssh-keys.json" { } ''
        ${yaml2json}/bin/yaml2json ${self}/keyring.yaml > $out
      ''
    )
  );

  # Extract only the keys from the YAML content
  keys = map (entry: entry.key) yamlContent;
in
{
  imports = [
    ./hardware-configuration.nix
    ./config/base.nix
    ./config/network.nix
    ./config/gnome.nix
    ./config/nvidia.nix
    ./config/services.nix
    ./config/samba.nix
    inputs.xremap-flake.nixosModules.default
  ];

  # Xremap needed configs
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "${user}" ];
  users.groups.input.members = [ "${user}" ];

  services.xremap = {
    withHypr = false;
    withGnome = true;
    withX11 = false;
    userName = "${user}";
    config = {
      keymap = [
        {
          name = "apps";
          remap = {
            super-y.launch = [ "firefox" ];
            C-alt-t.launch = [ "${pkgs.alacritty}/bin/alacritty" ];
          };
        }
      ];
    };
  };

  # System-wide configurations
  system.stateVersion = "24.05";
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Tailscale
  # services.nixos-tailscale = {
  #   enable = true;
  #   authKeyFile = config.sops.secrets.tailscale-auth-key.path;
  #   autoconnect = true;
  #   extraPackages = with pkgs; [
  #     openrgb-with-all-plugins
  #     linuxPackages.v4l2loopback
  #     v4l-utils
  #     inetutils
  #   ];
  # };

  # Graphics card
  #hardware.video.nvidia.gtx1080ti = {
  #  enable = true;
  #  enableCuda = true; # Enable if you need CUDA support
  #  enableVulkan = true;
  #  enable32bit = true;
  #  forceFullCompositionPipeline = true;
  #  powerManagement = false;
  #};

  # Motherboard
  #hardware.motherboards.z390AorusUltra = {
  #  enable = true;
  #  enableWifi = true;
  #  enableBluetooth = true;
  #  enableRgb = false;
  #  enableOptane = false;
  #};

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
  programs.zsh.enable = true;

  # Don't require password for users in `wheel` group for these commands
  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "${pkgs.systemd}/bin/reboot";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
      ];
    };
  };
}
