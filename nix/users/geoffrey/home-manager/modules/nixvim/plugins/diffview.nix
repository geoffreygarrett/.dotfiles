{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      package = pkgs.vimPlugins.diffview-nvim;
      diffBinaries = false;
      disableDefaultKeymaps = false;
      enhancedDiffHl = false;
      extraOptions = { };
      gitCmd = [ "git" ];
      hgCmd = [ "hg" ];
      showHelpHints = true;
      useIcons = true;
      watchIndex = true;
    };

    # You can add extra configuration if needed
    extraConfigLua = ''
      -- Add any additional Lua configuration for diffview here
    '';
  };
}
