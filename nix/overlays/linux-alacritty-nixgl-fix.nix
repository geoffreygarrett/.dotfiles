final: prev: {
  alacritty = final.lib.makeOverridable (
    {
      alacritty ? prev.alacritty,
      nixgl ? final.nixgl.auto.nixGLDefault,
    }:
    if final.stdenv.isLinux then
      final.writeShellScriptBin "alacritty" ''
        #!/bin/sh
        ${nixgl}/bin/nixGL ${alacritty}/bin/alacritty "$@"
      ''
    else
      alacritty
  ) { };
}
