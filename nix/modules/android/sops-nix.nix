{
  config,
  lib,
  pkgs,
  ...
}:

let
  sops-install-secrets = pkgs.sops-install-secrets;
  manifest = pkgs.writeTextFile {
    name = "manifest.json";
    text = builtins.toJSON {
      secrets = builtins.attrValues config.sops.secrets;
      secretsMountPoint = config.sops.defaultSecretsMountPoint;
      symlinkPath = config.sops.defaultSymlinkPath;
    };
  };
  script = pkgs.writeShellScript "sops-nix-user" ''
    ${lib.optionalString (config.sops.gnupg.home != null) ''
      export SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg
    ''}
    ${lib.optionalString config.sops.age.generateKey ''
      if [[ ! -f ${lib.escapeShellArg config.sops.age.keyFile} ]]; then
        echo "Generating machine-specific age key..."
        ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${lib.escapeShellArg config.sops.age.keyFile})
        ${pkgs.age}/bin/age-keygen -o ${lib.escapeShellArg config.sops.age.keyFile}
      fi
    ''}
    ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
  '';
in
{
  # Add the home activation script
  home.activation.sops-nix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $VERBOSE_ECHO "Setting up sops-nix for Nix-on-Droid..."
    ${script}
  '';
  # Override the default secrets mount point for Nix-on-Droid
  sops.defaultSecretsMountPoint = lib.mkForce "/data/data/com.termux.nix/files/home/.run/secrets";
  # Add a command to manually run sops-nix
  home.packages = [
    (pkgs.writeScriptBin "sops-nix-run" ''
      #!${pkgs.runtimeShell}
      echo "Running sops-nix manually..."
      ${script}
    '')
  ];
}
