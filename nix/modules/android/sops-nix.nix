{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
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
    ${optionalString (config.sops.gnupg.home != null) ''
      export SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg
    ''}
    ${optionalString config.sops.age.generateKey ''
      if [[ ! -f ${escapeShellArg config.sops.age.keyFile} ]]; then
        echo "Generating machine-specific age key..."
        ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapeShellArg config.sops.age.keyFile})
        ${pkgs.age}/bin/age-keygen -o ${escapeShellArg config.sops.age.keyFile}
      fi
    ''}
    ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
  '';

in
{

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
}
