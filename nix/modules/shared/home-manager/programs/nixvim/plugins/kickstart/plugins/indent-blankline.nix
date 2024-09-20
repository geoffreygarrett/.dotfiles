{
  programs.nixvim = {
    # Add indentation guides even on blank lines
    # For configuration see `:help ibl`
    # https://nix-community.github.io/nixvim/plugins/indent-blankline/settings/index.html
    plugins.indent-blankline = {
      enable = true;
      settings = {
        exclude = {
          buftypes = [
            "terminal"
            "quickfix"
          ];
          filetypes = [
            "checkhealth"
            "help"
            "lspinfo"
            "packer"
            "TelescopePrompt"
            "TelescopeResults"
            "yaml"
            "dashboard"
          ];
        };

        indent = {
          char = "│";
        };
        scope = {
          show_end = false;
          show_exact_scope = true;
          show_start = false;
        };
      };
    };
  };
}
