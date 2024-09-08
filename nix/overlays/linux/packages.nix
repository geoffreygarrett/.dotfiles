{ nixgl, lib, ... }:

self: super: {
  nixgl =
    if super.stdenv.isLinux && builtins.getEnv "TERMUX_APP__PACKAGE_NAME" == ""
    then nixgl.overlays.default self super
    else null;
}
