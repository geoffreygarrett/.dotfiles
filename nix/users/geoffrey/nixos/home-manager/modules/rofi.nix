{
  config,

  ...
}:

let
  base16 = config.colorScheme.palette;
in
{
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,run,window,ssh";
      icon-theme = "Papirus";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      disable-history = false;
      sidebar-mode = true;
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          bg-col = mkLiteral "#${base16.base00}";
          bg-col-light = mkLiteral "#${base16.base01}";
          border-col = mkLiteral "#${base16.base0D}";
          selected-col = mkLiteral "#${base16.base02}";
          blue = mkLiteral "#${base16.base0D}";
          fg-col = mkLiteral "#${base16.base05}";
          fg-col2 = mkLiteral "#${base16.base06}";
          grey = mkLiteral "#${base16.base03}";
        };
        "element-text, element-icon, mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        "window" = {
          height = mkLiteral "360px";
          border = mkLiteral "3px";
          border-color = mkLiteral "@border-col";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "12px";
          padding = "15px";
        };
        "mainbox" = {
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "12px";
        };
        "inputbar" = {
          children = mkLiteral "[prompt,entry]";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "2px";
        };
        "prompt" = {
          background-color = mkLiteral "@blue";
          padding = mkLiteral "6px";
          text-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "8px";
          margin = mkLiteral "20px 0px 0px 20px";
        };
        "textbox-prompt-colon" = {
          expand = false;
          str = ":";
        };
        "entry" = {
          padding = mkLiteral "6px";
          margin = mkLiteral "20px 0px 0px 10px";
          text-color = mkLiteral "@fg-col";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "8px";
        };
        "listview" = {
          border = mkLiteral "0px 0px 0px";
          padding = mkLiteral "6px 0px 0px";
          margin = mkLiteral "10px 0px 0px 20px";
          columns = 2;
          lines = 5;
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "8px";
        };
        "element" = {
          padding = mkLiteral "5px";
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@fg-col";
          border-radius = mkLiteral "6px";
        };
        "element-icon" = {
          size = mkLiteral "25px";
        };
        "element selected" = {
          background-color = mkLiteral "@selected-col";
          text-color = mkLiteral "@fg-col2";
          border-radius = mkLiteral "6px";
        };
        "mode-switcher" = {
          spacing = 0;
        };
        "button" = {
          padding = mkLiteral "10px";
          background-color = mkLiteral "@bg-col-light";
          text-color = mkLiteral "@grey";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.5";
          border-radius = mkLiteral "6px";
        };
        "button selected" = {
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@blue";
          border-radius = mkLiteral "6px";
        };
      };
  };
}
