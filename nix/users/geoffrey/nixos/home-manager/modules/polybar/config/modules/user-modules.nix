{
  pkgs,
  config,
  ...
}:

let
  base16 = config.colorScheme.palette;
  scripts = import ./scripts { inherit pkgs; };
in
{
  # services.polybar.config = {
  "module/updates" = {
    type = "custom/script";
    exec = "${scripts.updatesScript}/bin/polybar-updates";
    tail = "true";
    interval = "5";
    format = "<label>";
    format-prefix = "";
    format-prefix-foreground = "${base16.base0A}";
    label = " %output%";
    click-left = "${pkgs.xfce.exo}/bin/exo-open --launch TerminalEmulator &";
    click-right = "${pkgs.xfce.exo}/bin/exo-open --launch TerminalEmulator &";
  };

  "module/launcher" = {
    type = "custom/text";
    format = "  ";
    content-background = "#88${base16.base00}";
    content-foreground = "${base16.base0E}";
    content-padding = 2;
    click-left = "${scripts.launcherScript}/bin/polybar-launcher &";
    click-right = "${scripts.styleSwitchScript}/bin/polybar-style-switch &";
    border-size = 1;
    border-color = "#44${base16.base0E}";
  };

  "module/sysmenu" = {
    type = "custom/text";
    format = "  ";
    content-background = "#88${base16.base00}";
    content-foreground = "${base16.base0C}";
    content-padding = 2;
    click-left = "${scripts.powermenuScript}/bin/polybar-powermenu &";
    border-size = 1;
    border-color = "#44${base16.base0C}";
  };

  "module/color-switch" = {
    type = "custom/text";
    content = "";
    content-foreground = "${base16.base08}";
    click-left = "${scripts.styleSwitchScript}/bin/polybar-style-switch &";
  };

  "module/sep" = {
    type = "custom/text";
    content = "|";
    content-foreground = "${base16.base03}";
  };

  "module/term" = {
    type = "custom/text";
    content = "";
    content-foreground = "${base16.base05}";
    click-left = "${pkgs.termite}/bin/termite &";
    click-middle = "${pkgs.rxvt-unicode}/bin/urxvt &";
    click-right = "${pkgs.alacritty}/bin/alacritty &";
  };

  "module/files" = {
    type = "custom/text";
    content = "";
    content-foreground = "${base16.base0D}";
    click-left = "${pkgs.xfce.thunar}/bin/thunar &";
    click-right = "${pkgs.pcmanfm}/bin/pcmanfm &";
  };

  "module/browser" = {
    type = "custom/text";
    content = "";
    content-foreground = "${base16.base09}";
    click-left = "${pkgs.firefox}/bin/firefox &";
    click-right = "${pkgs.chromium}/bin/chromium &";
  };

  "module/settings" = {
    type = "custom/text";
    content = "";
    content-foreground = "${base16.base0B}";
    click-left = "${pkgs.xfce.xfce4-settings}/bin/xfce4-settings-manager &";
    click-right = "${pkgs.lxappearance}/bin/lxappearance &";
  };

  "module/powermenu" = {
    type = "custom/menu";
    expand-right = "true";
    menu-0-0 = " Reboot |";
    menu-0-0-exec = "menu-open-1";
    menu-0-1 = " Shutdown ";
    menu-0-1-exec = "menu-open-2";
    menu-1-0 = " Back |";
    menu-1-0-exec = "menu-open-0";
    menu-1-1 = " Reboot ";
    menu-1-1-exec = "systemctl reboot";
    menu-2-0 = " Shutdown |";
    menu-2-0-exec = "systemctl poweroff";
    menu-2-1 = " Back ";
    menu-2-1-exec = "menu-open-0";
    format = "<label-toggle><menu>";
    label-open = "";
    label-open-foreground = "${base16.base0C}";
    label-open-padding = "1";
    label-close = "";
    label-close-foreground = "${base16.base08}";
    label-close-padding = "1";
  };

  "module/menu" = {
    type = "custom/menu";
    expand-right = "true";
    menu-0-0 = "  Menu | ";
    menu-0-0-exec = "${scripts.launcherScript}/bin/polybar-launcher &";
    menu-0-1 = " Files | ";
    menu-0-1-exec = "${pkgs.xfce.thunar}/bin/thunar &";
    menu-0-2 = " Terminal | ";
    menu-0-2-exec = "${pkgs.termite}/bin/termite &";
    menu-0-3 = " Browser ";
    menu-0-3-exec = "${pkgs.firefox}/bin/firefox &";
    format = "<label-toggle><menu>";
    label-open = "";
    label-open-foreground = "${base16.base0A}";
    label-open-padding = "1";
    label-close = "";
    label-close-foreground = "${base16.base08}";
    label-close-padding = "1";
  };
  # };
}
