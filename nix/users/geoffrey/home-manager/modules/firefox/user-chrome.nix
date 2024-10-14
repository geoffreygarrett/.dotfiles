{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = config.colorScheme.palette;
in
''
  /* Deep Ocean Theme for Firefox - User Chrome */
  :root {
    /* Main Colors */
    --deep-background: #${theme.base00};
    --deep-foreground: #${theme.base04};
    --deep-text: #${theme.base03};
    --deep-selection-bg: #717CB480;
    --deep-selection-fg: #${theme.base07};
    --deep-accent: #84FFFF;

    /* UI Elements */
    --deep-buttons: #191A21;
    --deep-second-bg: #${theme.base01};
    --deep-disabled: #464B5D;
    --deep-contrast: #090B10;
    --deep-active: #1A1C25;
    --deep-border: #${theme.base00};
    --deep-highlight: #${theme.base02};

    /* Syntax Colors */
    --deep-green: #${theme.base0B};
    --deep-yellow: #${theme.base0A};
    --deep-blue: #${theme.base0D};
    --deep-red: #${theme.base08};
    --deep-purple: #${theme.base0E};
    --deep-orange: #${theme.base09};
    --deep-cyan: #${theme.base0C};
    --deep-gray: #${theme.base06};
    --deep-white: #${theme.base05};
    --deep-error: #${theme.base0F};
  }

  /* Styling Toolbar */
  #navigator-toolbox {
    --lwt-tabs-border-color: var(--deep-border) !important;
  }

  #tabbrowser-tabs {
    --lwt-tab-line-color: var(--deep-accent) !important;
  }

  #TabsToolbar { -moz-box-ordinal-group: 2; }

  /* Sidebar Styling */
  #sidebar-box {
    --sidebar-background-color: var(--deep-second-bg) !important;
  }
''
