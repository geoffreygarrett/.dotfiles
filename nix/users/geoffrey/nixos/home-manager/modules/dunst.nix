{
  config,
  ...
}:

let
  base16 = config.colorScheme.palette;
in
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "JetBrains Mono 10";
        markup = "full";
        format = "<b>%s</b>\n%b";
        sort = "yes";
        indicate_hidden = "yes";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        geometry = "300x5-30+20";
        shrink = "no";
        transparency = 10;
        idle_threshold = 120;
        monitor = 0;
        follow = "mouse";
        sticky_history = "yes";
        history_length = 20;
        show_indicators = "yes";
        line_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        separator_color = "frame";
        startup_notification = false;
        frame_width = 2;
        frame_color = "#${base16.base0D}";
      };
      urgency_low = {
        background = "#${base16.base00}";
        foreground = "#${base16.base05}";
        timeout = 10;
      };
      urgency_normal = {
        background = "#${base16.base00}";
        foreground = "#${base16.base05}";
        timeout = 10;
      };
      urgency_critical = {
        background = "#${base16.base00}";
        foreground = "#${base16.base08}";
        frame_color = "#${base16.base08}";
        timeout = 0;
      };
    };
  };
}
