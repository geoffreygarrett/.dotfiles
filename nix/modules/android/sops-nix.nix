{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.sops-nix;
  sops-install-secrets = pkgs.sops-install-secrets;

  manifest = pkgs.writeTextFile {
    name = "manifest.json";
    text = builtins.toJSON {
      secrets = builtins.attrValues cfg.secrets;
      secretsMountPoint = cfg.defaultSecretsMountPoint;
      symlinkPath = cfg.defaultSymlinkPath;
    };
  };

  script = pkgs.writeShellScript "sops-nix-user" ''
    ${optionalString (cfg.gnupg.home != null) ''
      export SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg
    ''}
    ${optionalString cfg.age.generateKey ''
      if [[ ! -f ${escapeShellArg cfg.age.keyFile} ]]; then
        echo "Generating machine-specific age key..."
        ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapeShellArg cfg.age.keyFile})
        ${pkgs.age}/bin/age-keygen -o ${escapeShellArg cfg.age.keyFile}
      fi
    ''}
    ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
  '';

in
{
  config = mkIf cfg.enable {
    # Override the default secrets mount point for Nix-on-Droid
    services.sops-nix.defaultSecretsMountPoint = mkForce "/data/data/com.termux.nix/files/home/.local/share/secrets";

    # Ensure the secrets directory exists
    home.file.".local/share/secrets/.keep".text = "";

    # Add the build activation script
    build.activation.sops-nix = ''
      $VERBOSE_ECHO "Setting up sops-nix for Nix-on-Droid..."
      ${script}
    '';

    # Add a command to manually run sops-nix
    environment.packages = [
      (pkgs.writeScriptBin "sops-nix-run" ''
        #!${pkgs.runtimeShell}
        echo "Running sops-nix manually..."
        ${script}
      '')
    ];
  };
}
