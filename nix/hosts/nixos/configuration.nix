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
    ############################
    # Hardware
    ############################
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.sops-nix.nixosModules.default
    inputs.xremap-flake.nixosModules.default
    ./config/base.nix
    ./modules/z390-aorus-ultra.nix
    ./modules/focusrite-scarlett-solo-gen3.nix
    ./config/network.nix
    #./config/gnome.nix
    #./config/nvidia.nix
    ./modules/desktop-environment.nix
    ./config/services.nix
    ./config/samba.nix
    ../../modules/shared/secrets.nix

  ];

  desktopEnvironment.use = "bspwm"; # or "i3" or "gnome"
  hardware.nvidia.open = false; # Disable open source
  hardware.enableAllFirmware = true;
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "${user}" ];
  users.groups.input.members = [ "${user}" ];

  hardware.focusrite-scarlett-solo-gen3 = {
    enable = true;
    defaultSampleRate = 44100;
    useAlsa = true;
    usePulseAudio = true;
    usePipeWire = true;
  };

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
            {
              command = "/run/current-system/sw/bin/mount.cifs";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/umount";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
      ];
    };
  };

  # # Ensure the custom icon is copied to the proper location
  # environment.etc."icons/alacritty-neovim.png".source = ../../modules/shared/assets/alacritty/flat/alacritty_flat_512.png;
  #
  # # Define the .desktop file for opening with Alacritty and Neovim
  # environment.etc."xdg/applications/alacritty-neovim.desktop".text = ''
  #   [Desktop Entry]
  #   Version=1.0
  #   Name=Alacritty with Neovim
  #   Comment=Open files with Neovim inside Alacritty
  #   Exec=${pkgs.alacritty}/bin/alacritty -e ${pkgs.neovim}/bin/nvim %F
  #   Terminal=false
  #   Type=Application
  #   MimeType=text/plain;application/x-shellscript;
  #   Icon=/etc/icons/alacritty-neovim.png
  #   Categories=Utility;TextEditor;
  # '';
}
