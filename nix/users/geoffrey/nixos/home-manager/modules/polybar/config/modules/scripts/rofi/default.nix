{
  pkgs,
}:

let
  colorScheme = {
    al = "00000000";
    bg = "212B30FF";
    bga = "263035FF";
    fg = "C4C7C5FF";
    ac = "EC407AFF";
    se = "4DD0E1FF";
  };

  generateRasi =
    name: content:
    pkgs.writeText "${name}.rasi" ''
      /* Generated ${name}.rasi */
      ${content}
    '';

in
{

  colorsRasi = generateRasi "colors" ''
    * {
      al:   #${colorScheme.al};
      bg:   #${colorScheme.bg};
      bga:  #${colorScheme.bga};
      fg:   #${colorScheme.fg};
      ac:   #${colorScheme.ac};
      se:   #${colorScheme.se};
    }
  '';

  confirmRasi = generateRasi "confirm" ''
    @import "colors.rasi"
    * {
      background-color:       @bg;
      text-color:             @fg;
      font:                   "Iosevka Nerd Font 10";
    }
    window {
      width:                  210px;
      padding:                25px;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      location:               center;
      y-offset:               -2em;
    }
    entry {
      expand:                 true;
      text-color:             @ac;
    }
  '';

  launcherRasi = generateRasi "launcher" ''
    /*
     *
     * Author  : Aditya Shakya
     * Mail    : adi1090x@gmail.com
     * Github  : @adi1090x
     * Twitter : @adi1090x
     *
     */
    configuration {
      font:                   "Iosevka Nerd Font 10";
      show-icons:             true;
      icon-theme:             "Papirus";
      display-drun:           "";
      drun-display-format:    "{name}";
      disable-history:        false;
      fullscreen:             false;
      hide-scrollbar:         true;
      sidebar-mode:           false;
    }
    @import "colors.rasi"
    window {
      transparency:           "real";
      background-color:       @bg;
      text-color:             @fg;
      border:                 0px 0px 0px 0px;
      border-color:           @ac;
      border-radius:          0px;
      width:                  500px;
      location:               center;
      x-offset:               0;
      y-offset:               0;
    }
    prompt {
      enabled:                true;
      padding:                0px;
      background-color:       @bga;
      text-color:             @ac;
      font:                   "feather 12";
    }
    entry {
      background-color:       @al;
      text-color:             @fg;
      placeholder-color:      @fg;
      expand:                 true;
      horizontal-align:       0;
      placeholder:            "Search...";
      padding:                0px 0px 0px 5px;
      blink:                  true;
    }
    inputbar {
      children:               [ prompt, entry ];
      background-color:       @bga;
      text-color:             @fg;
      expand:                 false;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      margin:                 0px;
      padding:                10px;
    }
    listview {
      background-color:       @al;
      padding:                0px;
      columns:                1;
      lines:                  6;
      spacing:                5px;
      cycle:                  true;
      dynamic:                true;
      layout:                 vertical;
    }
    mainbox {
      background-color:       @al;
      border:                 0px;
      border-radius:          0px;
      border-color:           @ac;
      children:               [ inputbar, listview ];
      spacing:                5px;
      padding:                5px;
    }
    element {
      background-color:       @al;
      text-color:             @fg;
      orientation:            horizontal;
      border-radius:          0px;
      padding:                8px;
    }
    element-icon {
      background-color:       transparent;
      text-color:             inherit;
      size:                   24px;
      border:                 0px;
    }
    element-text {
      background-color:       transparent;
      text-color:             inherit;
      expand:                 true;
      horizontal-align:       0;
      vertical-align:         0.5;
      margin:                 0px 2.5px 0px 2.5px;
    }
    element selected {
      background-color:       @se;
      text-color:             @bg;
      border:                 0px 0px 0px 0px;
      border-radius:          0px;
      border-color:           @ac;
    }
  '';

  messageRasi = generateRasi "message" ''
    @import "colors.rasi"
    * {
      background-color:       @bg;
      text-color:             @fg;
      font:                   "Iosevka Nerd Font 10";
    }
    window {
      width:                  320px;
      padding:                25px;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      location:               center;
      y-offset:               -2em;
    }
    entry {
      expand:                 true;
      text-color:             @ac;
    }
  '';

  networkMenuRasi = generateRasi "networkmenu" ''
    /*
     *
     * Author  : Aditya Shakya
     * Mail    : adi1090x@gmail.com
     * Github  : @adi1090x
     * Twitter : @adi1090x
     *
     */
    configuration {
      font:                   "Iosevka Nerd Font 10";
      show-icons:             true;
      icon-theme:             "Papirus";
      display-drun:           "";
      drun-display-format:    "{name}";
      disable-history:        false;
      fullscreen:             false;
      hide-scrollbar:         true;
      sidebar-mode:           false;
    }
    @import "colors.rasi"
    window {
      transparency:           "real";
      background-color:       @bg;
      text-color:             @fg;
      border:                 0px 0px 0px 0px;
      border-color:           @ac;
      border-radius:          0px;
      width:                  400px;
      location:               center;
      x-offset:               0;
      y-offset:               0;
    }
    prompt {
      enabled:                true;
      padding:                0px 0px 0px 10px;
      background-color:       @bga;
      text-color:             @fg;
    }
    textbox-prompt-colon {
      padding:                0px;
      background-color:       @bga;
      text-color:             @ac;
      expand:                 false;
      str:                    "";
      font:                   "feather 12";
    }
    entry {
      background-color:       @al;
      text-color:             @fg;
      placeholder-color:      @fg;
      expand:                 true;
      horizontal-align:       0;
      placeholder:            "Search...";
      padding:                0px 0px 0px 5px;
      blink:                  true;
    }
    inputbar {
      children:               [ textbox-prompt-colon, prompt ];
      background-color:       @bga;
      text-color:             @fg;
      expand:                 false;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      margin:                 0px;
      padding:                10px;
    }
    listview {
      background-color:       @al;
      padding:                0px;
      columns:                1;
      lines:                  8;
      spacing:                5px;
      cycle:                  true;
      dynamic:                true;
      layout:                 vertical;
    }
    mainbox {
      background-color:       @al;
      border:                 0px;
      border-radius:          0px;
      border-color:           @ac;
      children:               [ inputbar, listview ];
      spacing:                5px;
      padding:                5px;
    }
    element {
      background-color:       @al;
      text-color:             @fg;
      orientation:            horizontal;
      border-radius:          0px;
      padding:                8px 8px 8px -15px;
    }
    element-icon {
      background-color:       transparent;
      text-color:             inherit;
      size:                   24px;
      border:                 0px;
    }
    element-text {
      background-color:       transparent;
      text-color:             inherit;
      expand:                 true;
      horizontal-align:       0;
      vertical-align:         0.5;
      margin:                 0px 2.5px 0px 2.5px;
    }
    element selected {
      background-color:       @se;
      text-color:             @bg;
      border:                 0px 0px 0px 0px;
      border-radius:          0px;
      border-color:           @ac;
    }
  '';

  powerMenuRasi = generateRasi "powermenu" ''
    /*
     *
     * Author  : Aditya Shakya
     * Mail    : adi1090x@gmail.com
     * Github  : @adi1090x
     * Twitter : @adi1090x
     *
     */
    configuration {
      font:                   "Iosevka Nerd Font 10";
      show-icons:             true;
      icon-theme:             "Papirus";
      display-drun:           "";
      drun-display-format:    "{name}";
      disable-history:        false;
      fullscreen:             false;
      hide-scrollbar:         true;
      sidebar-mode:           false;
    }
    @import "colors.rasi"
    window {
      transparency:           "real";
      background-color:       @bg;
      text-color:             @fg;
      border:                 0px 0px 0px 0px;
      border-color:           @ac;
      border-radius:          0px;
      width:                  350px;
      location:               center;
      x-offset:               0;
      y-offset:               0;
    }
    prompt {
      enabled:                true;
      padding:                0px 0px 0px 10px;
      background-color:       @bga;
      text-color:             @fg;
    }
    textbox-prompt-colon {
      padding:                0px;
      background-color:       @bga;
      text-color:             @ac;
      expand:                 false;
      str:                    "";
      font:                   "feather 12";
    }
    entry {
      background-color:       @al;
      text-color:             @fg;
      placeholder-color:      @fg;
      expand:                 true;
      horizontal-align:       0;
      placeholder:            "Search...";
      padding:                0px 0px 0px 5px;
      blink:                  true;
    }
    inputbar {
      children:               [ textbox-prompt-colon, prompt ];
      background-color:       @bga;
      text-color:             @fg;
      expand:                 false;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      margin:                 0px;
      padding:                10px;
    }
    listview {
      background-color:       @al;
      padding:                0px;
      columns:                1;
      lines:                  5;
      spacing:                5px;
      cycle:                  true;
      dynamic:                true;
      layout:                 vertical;
    }
    mainbox {
      background-color:       @al;
      border:                 0px;
      border-radius:          0px;
      border-color:           @ac;
      children:               [ inputbar, listview ];
      spacing:                5px;
      padding:                5px;
    }
    element {
      background-color:       @al;
      text-color:             @fg;
      orientation:            horizontal;
      border-radius:          0px;
      padding:                8px 8px 8px -20px;
    }
    element-icon {
      background-color:       transparent;
      text-color:             inherit;
      size:                   24px;
      border:                 0px;
    }
    element-text {
      background-color:       transparent;
      text-color:             inherit;
      expand:                 true;
      horizontal-align:       0;
      vertical-align:         0.5;
      margin:                 0px 2.5px 0px 2.5px;
    }
    element selected {
      background-color:       @se;
      text-color:             @bg;
      border:                 0px 0px 0px 0px;
      border-radius:          0px;
      border-color:           @ac;
    }
  '';

  stylesRasi = generateRasi "styles" ''
    /*
     *
     * Author  : Aditya Shakya
     * Mail    : adi1090x@gmail.com
     * Github  : @adi1090x
     * Twitter : @adi1090x
     *
     */
    configuration {
      font:                   "Iosevka Nerd Font 10";
      show-icons:             true;
      icon-theme:             "Papirus";
      display-drun:           "";
      drun-display-format:    "{name}";
      disable-history:        false;
      fullscreen:             false;
      hide-scrollbar:         true;
      sidebar-mode:           false;
    }
    @import "colors.rasi"
    window {
      transparency:           "real";
      background-color:       @bg;
      text-color:             @fg;
      border:                 0px 0px 0px 0px;
      border-color:           @ac;
      border-radius:          0px;
      width:                  350px;
      location:               center;
      x-offset:               0;
      y-offset:               0;
    }
    prompt {
      enabled:                true;
      padding:                0px 0px 0px 5px;
      background-color:       @bga;
      text-color:             @fg;
    }
    textbox-prompt-colon {
      padding:                0px;
      background-color:       @bga;
      text-color:             @ac;
      expand:                 false;
      str:                    "";
      font:                   "feather 12";
    }
    entry {
      background-color:       @al;
      text-color:             @fg;
      placeholder-color:      @fg;
      expand:                 true;
      horizontal-align:       0;
      placeholder:            "Search...";
      padding:                0px 0px 0px 10px;
      blink:                  true;
    }
    inputbar {
      children:               [ textbox-prompt-colon, entry ];
      background-color:       @bga;
      text-color:             @fg;
      expand:                 false;
      border:                 0px 0px 1px 0px;
      border-radius:          0px;
      border-color:           @se;
      margin:                 0px;
      padding:                10px;
    }
    listview {
      background-color:       @al;
      padding:                0px;
      columns:                1;
      lines:                  5;
      spacing:                5px;
      cycle:                  true;
      dynamic:                true;
      layout:                 vertical;
    }
    mainbox {
      background-color:       @al;
      border:                 0px;
      border-radius:          0px;
      border-color:           @ac;
      children:               [ inputbar, listview ];
      spacing:                5px;
      padding:                5px;
    }
    element {
      background-color:       @al;
      text-color:             @fg;
      orientation:            horizontal;
      border-radius:          0px;
      padding:                8px 8px 8px -20px;
    }
    element-icon {
      background-color:       transparent;
      text-color:             inherit;
      size:                   24px;
      border:                 0px;
    }
    element-text {
      background-color:       transparent;
      text-color:             inherit;
      expand:                 true;
      horizontal-align:       0;
      vertical-align:         0.5;
      margin:                 0px 2.5px 0px 2.5px;
    }
    element selected {
      background-color:       @se;
      text-color:             @bg;
      border:                 0px 0px 0px 0px;
      border-radius:          0px;
      border-color:           @ac;
    }
  '';
}
