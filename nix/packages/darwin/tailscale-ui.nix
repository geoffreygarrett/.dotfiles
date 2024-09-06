# =============================================================================
# Title: Tailscale UI for macOS Derivation
#
# Description:
#   This derivation installs the Tailscale UI for macOS, a user interface for
#   managing Tailscale networks. The package is distributed as a pre-built
#   application bundle, which is extracted and installed by this derivation.
#
# Usage:
#   This derivation can be used as part of a Home Manager configuration to
#   install Tailscale UI on macOS systems.
#
# Inputs:
#   - lib: Standard Nix library functions.
#   - stdenvNoCC: A standard environment without a C compiler, used for
#     installing the package.
#   - fetchurl: Function to download the source package from a URL.
#   - unzip: Tool for unpacking ZIP archives.
#
# Metadata:
#   - Homepage: https://tailscale.com
#   - Description: User interface for Tailscale, a zero config VPN.
#   - License: Proprietary
#   - Platforms: x86_64-darwin, aarch64-darwin
# =============================================================================

{ lib
, stdenvNoCC
, fetchurl
, unzip
, runCommand
, writeShellScriptBin
}:


let
  tailscaleUiCli = writeShellScriptBin "tailscale-ui" ''
    echo "Attempting to open the specific Tailscale.app installed by this derivation..."

    # Resolve the actual location of the script and go up to the Applications folder
    app_dir=$(dirname $(dirname $0))/Applications/Tailscale.app

    if [ -d "$app_dir" ]; then
      echo "Found Tailscale.app in $app_dir, launching..."
      open "$app_dir"
    else
      echo "Tailscale.app not found at expected path: $app_dir"
      exit 1
    fi

    echo "Tailscale.app launch attempt complete."
  '';
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tailscale-ui";
  version = "1.72.2";
  sha256 = "6c3589ecd18722cce4be8585628e165d901d041610fdcd0833120627845b4fd1";

  src = fetchurl {
    name = "${finalAttrs.pname}-${finalAttrs.version}.zip";
    url = "https://pkgs.tailscale.com/stable/Tailscale-${finalAttrs.version}-macos.zip";
    sha256 = finalAttrs.sha256;
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r Tailscale.app $out/Applications/
    mkdir -p $out/bin
    ln -s ${tailscaleUiCli}/bin/tailscale-ui $out/bin/tailscale-ui
    runHook postInstall
  '';

  outputs = [ "out" ];

  meta = with lib; {
    description = "Tailscale UI for macOS - Zero config VPN";
    longDescription = ''
      Tailscale is a zero config VPN, which creates a secure network between your
      devices. Tailscale UI for macOS provides a user-friendly interface to manage
      your Tailscale network on macOS systems.
    '';
    homepage = "https://tailscale.com";
    changelog = "https://github.com/tailscale/tailscale/releases/tag/v${finalAttrs.version}";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "tailscale-ui";
  };
})
