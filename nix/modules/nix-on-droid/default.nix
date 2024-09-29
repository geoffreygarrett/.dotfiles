{
  self,
  config,
  lib,
  pkgs,
  keys,
  user,
  services,
  ...
}:
let
  sops-config = config.home-manager.config.sops;
  sops-install-secrets = pkgs.sops-install-secrets;
  manifestFor =
    suffix: secrets:
    pkgs.writeTextFile {
      name = "manifest${suffix}.json";
      text = builtins.toJSON {
        secrets = builtins.attrValues secrets;
        secretsMountPoint = sops-config.defaultSecretsMountPoint;
        symlinkPath = sops-config.defaultSymlinkPath;
        keepGenerations = sops-config.keepGenerations;
        gnupgHome = sops-config.gnupg.home;
        sshKeyPaths = sops-config.gnupg.sshKeyPaths;
        ageKeyFile = sops-config.age.keyFile;
        ageSshKeyPaths = sops-config.age.sshKeyPaths;
        userMode = true;
        logging = {
          keyImport = builtins.elem "keyImport" sops-config.log;
          secretChanges = builtins.elem "secretChanges" sops-config.log;
        };
      };
      checkPhase = ''
        ${sops-install-secrets}/bin/sops-install-secrets -check-mode=${
          if sops-config.validateSopsFiles then "sopsfile" else "manifest"
        } "$out"
      '';
    };
  manifest = manifestFor "" sops-config.secrets;
  escapedAgeKeyFile = lib.escapeShellArg sops-config.age.keyFile;
  script = toString (
    pkgs.writeShellScript "sops-nix-user" (
      (lib.optionalString (sops-config.gnupg.home != null) ''
        export SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg
      '')
      + (
        lib.optionalString sops-config.age.generateKey ''
          if [[ ! -f ${escapedAgeKeyFile} ]]; then
            echo generating machine-specific age key...
            ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapedAgeKeyFile})
            # age-keygen sets 0600 by default, no need to chmod.
            ${pkgs.age}/bin/age-keygen -o ${escapedAgeKeyFile}
          fi
        ''
        + ''
          ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
        ''
      )
    )
  );

in
{
  imports = [
    ./config/services.nix
    ./config/openssh.nix

  ];

  # System Configuration
  system.stateVersion = "24.05";

  # Nixpkgs Configuration
  # nixpkgs.config = { };
  # nixpkgs.overlays = [ ];

  services.openssh = {
    enable = true;
    port = 8022;
    authorizedKeys = keys;
    autoStart = true;
    keepAlive = true;
  };

  # Terminal Configuration
  terminal = {
    font = "${
      pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }
    }/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFontMono-Regular.ttf";
    colors = {
      background = "#0F111A";
      foreground = "#8F93A2";
      cursor = "#84ffff";
      color0 = "#090B10";
      color1 = "#f07178";
      color2 = "#c3e88d";
      color3 = "#ffcb6b";
      color4 = "#82aaff";
      color5 = "#c792ea";
      color6 = "#89ddff";
      color7 = "#eeffff";
      color8 = "#464B5D";
      color9 = "#ff5370";
      color10 = "#c3e88d";
      color11 = "#f78c6c";
      color12 = "#80cbc4";
      color13 = "#c792ea";
      color14 = "#89ddff";
      color15 = "#ffffff";
    };
  };

  # Android Integration
  android-integration = {
    am.enable = true;
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-reload-settings.enable = true;
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    unsupported.enable = false;
    xdg-open.enable = true;
  };

  # Home Manager Configuration
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit (config) services;
      inherit self;
    };
    config = import ./home-manager.nix;
  };

  # Build Configuration
  build.activation.sops-nix = ''
    $VERBOSE_ECHO "Setting up sops-nix for Nix-on-Droid..."
    ${script}
  '';

  # Build Configuration
  # build = {
  #   activation = { };
  #   activationBefore = { };
  #   activationAfter = { };
  # };
}
