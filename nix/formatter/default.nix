{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    beautysh.enable = true;
    rustfmt.enable = true;
    yamlfmt.enable = true;
    taplo.enable = true;
    mdformat.enable = true;
    stylua.enable = true;
    prettier.enable = true;
  };

  settings.formatter =
    let
      # Define the common settings once
      common = {
        excludes = [
          "*.png"
          "*.jpg"
          "*.jpeg"
          "*.gif"
          "*.svg"
        ];
      };
    in
    {
      nixfmt = common // {
        includes = [ "*.nix" ];
      };

      beautysh = common // {
        includes = [
          "*.sh"
          "*.ps1"
        ];
      };

      rustfmt = common // {
        includes = [ "*.rs" ];
      };

      yamlfmt = common // {
        includes = [
          "*.yaml"
          "*.yml"
        ];
      };

      taplo = common // {
        includes = [ "*.toml" ];
      };

      mdformat = common // {
        includes = [ "*.md" ];
      };

      stylua = common // {
        includes = [ "*.lua" ];
      };

      prettier = common // {
        includes = [
          "*.json"
          "*.js"
          "*.ts"
          "*.html"
          "*.css"
          "*.scss"
          "*.md"
          "*.yaml"
          "*.yml"
        ];
        options = [
          "--prose-wrap"
          "always"
        ];
      };
    };
}
