# File: nix/overlays/packages-overlay.nix

self: super: {
  # Import your overlay packages, such as common and darwin-specific packages
  makeWrapper = import ../packages/make-wrapper.nix { inherit (super) writeShellScriptBin; };

  # Darwin-specific packages
  tailscale-ui = if super.stdenv.isDarwin then super.callPackage ../packages/darwin/tailscale-ui.nix { } else null;

  hammerspoon = if super.stdenv.isDarwin then super.callPackage ../packages/darwin/hammerspoon.nix { } else null;

  # Linux-specific (excluding Termux)
  nixgl =
    if super.stdenv.isLinux && builtins.getEnv "TERMUX_APP__PACKAGE_NAME" == ""
    then super.callPackage (import nixgl.overlays.default) { }
    else null;

  # Add other packages common to all systems
  # my-common-package = super.callPackage ../packages/common/my-package.nix { };
}
