({ pkgs, ... }:
  let myPkgs = mkPkgs "x86_64-linux";
  in {
    home.packages = [ myPkgs.nixgl.auto.nixGLDefault ];
    home.file.".local/bin/alacritty-gl" = {
      text = ''
        #!/bin/sh
        ${myPkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
      '';
      executable = true;
    };
    home.sessionVariables = {
      NIXGL = "${myPkgs.nixgl.auto.nixGLDefault}/bin/nixGL";
    };
  })
