{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    beautysh.enable = true;
    rustfmt.enable = true;
    yamlfmt.enable = true;
    taplo.enable = true;
    # mdformat.enable = true;
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
          "*.bak"
          "*.off"
          "*.png"
          ".DS_Store"
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

      # TODO: Try get github flavored markdown working
      # mdformat = common // {
      #   includes = [ "*.md" ];
      #   options = [
      #     "--wrap"
      #     "80"
      #     "--number"
      #   ];
      # };

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
