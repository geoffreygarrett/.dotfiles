{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.nixvim = {
    plugins.rustaceanvim = {
      enable = true;
    };
    plugins.dap = {
      enable = true;
    };
  };

  # Add VSCode C/C++ tools
  home.packages = with pkgs; [
    #vscode-extensions.ms-vscode.cpptools # NOTE: Not compatible with aarch64-darwin
  ];

}
