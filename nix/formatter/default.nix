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
  settings.formatter = {
    nixfmt.includes = [ "*.nix" ];
    beautysh.includes = [
      "*.sh"
      "*.ps1"
    ];
    rustfmt.includes = [ "*.rs" ];
    yamlfmt.includes = [
      "*.yaml"
      "*.yml"
    ];
    taplo.includes = [ "*.toml" ];
    mdformat.includes = [ "*.md" ];
    stylua.includes = [ "*.lua" ];
    prettier = {
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
