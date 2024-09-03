# =============================================================================
# Title: Hammerspoon Derivation
#
# Description:
#   This derivation builds and installs Hammerspoon, a powerful macOS desktop
#   automation tool using Lua. The package cannot be built from source due to
#   the requirement for entitlements, which are incompatible with Nix's
#   immutability.
#
# Attribution:
#   Thanks to Qyriad for the original gist:
#   https://gist.github.com/Qyriad/a81f644c0199076577726983bd7f533a
#
# Usage:
#   This derivation can be used as part of a Nix expression to install
#   Hammerspoon on macOS systems.
#
# Inputs:
#   - lib: Standard Nix library functions.
#   - stdenvNoCC: A standard environment without a C compiler, used for
#     building the package.
#   - fetchurl: Function to download the source package from a URL.
#   - unzip: Tool for unpacking ZIP archives.
#
# Metadata:
#   - Homepage: https://www.hammerspoon.org
#   - Description: Staggeringly powerful macOS desktop automation with Lua.
#   - License: MIT
#   - Platforms: x86_64-darwin, aarch64-darwin
# =============================================================================

{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (self: {
  pname = "hammerspoon";
  version = "0.9.100";

  # We don't use fetchzip because that seems to unpack the .app as well.
  src = fetchurl {
    name = "${self.pname}-${self.version}-source.zip";
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${self.version}/Hammerspoon-${self.version}.zip";
    sha256 = "sha256-bc/IB8fOxpLK87GMNsweo69rn0Jpm03yd3NECOTgc5k=";
  };

  nativeBuildInputs = [
    # Adds unpack hook.
    unzip
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r ../Hammerspoon.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.hammerspoon.org";
    description = "Staggeringly powerful macOS desktop automation with Lua";
    license = lib.licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
})
