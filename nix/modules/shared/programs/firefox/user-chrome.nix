{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = config.theme;
in
''
  /* Deep Ocean Theme for Firefox
     Original theme colors by MrOtherGuy
     Adapted and organized for Nix configuration */

  :root {
    /* Main Colors */
    --deep-background: #${theme.extra.background};
    --deep-foreground: #${theme.extra.foreground};
    --deep-text: #${theme.extra.text};
    --deep-selection-bg: #${theme.extra.selection_background};
    --deep-selection-fg: #${theme.extra.selection_foreground};
    --deep-accent: #${theme.extra.accent_color};

    /* UI Elements */
    --deep-buttons: #${theme.extra.buttons};
    --deep-second-bg: #${theme.extra.second_background};
    --deep-disabled: #${theme.extra.disabled};
    --deep-contrast: #${theme.extra.contrast};
    --deep-active: #${theme.extra.active};
    --deep-border: #${theme.extra.border};
    --deep-highlight: #${theme.extra.highlight};

    /* Special Elements */
    --deep-tree: #${theme.extra.tree};
    --deep-notifications: #${theme.extra.notifications};
    --deep-excluded-files: #${theme.extra.excluded_files};

    /* Syntax Colors */
    --deep-green: #${theme.extra.green};
    --deep-yellow: #${theme.extra.yellow};
    --deep-blue: #${theme.extra.blue};
    --deep-red: #${theme.extra.red};
    --deep-purple: #${theme.extra.purple};
    --deep-orange: #${theme.extra.orange};
    --deep-cyan: #${theme.extra.cyan};
    --deep-gray: #${theme.extra.gray};
    --deep-white: #${theme.extra.white_black};
    --deep-error: #${theme.extra.error};

    /* Code Elements */
    --deep-comments: #${theme.extra.comments};
    --deep-variables: #${theme.extra.variables};
    --deep-links: #${theme.extra.links};
    --deep-functions: #${theme.extra.functions};
    --deep-keywords: #${theme.extra.keywords};
    --deep-tags: #${theme.extra.tags};
    --deep-strings: #${theme.extra.strings};
    --deep-operators: #${theme.extra.operators};
    --deep-attributes: #${theme.extra.attributes};
    --deep-numbers: #${theme.extra.numbers};
    --deep-parameters: #${theme.extra.parameters};

    /* Popup panels */
    --arrowpanel-background: var(--deep-second-bg) !important;
    --arrowpanel-border-color: var(--deep-border) !important;
    --arrowpanel-color: var(--deep-text) !important;
    --arrowpanel-dimmed: var(--deep-contrast)80 !important;

    /* Window and toolbar background */
    --lwt-accent-color: var(--deep-background) !important;
    --lwt-accent-color-inactive: var(--deep-second-bg) !important;
    --toolbar-bgcolor: var(--deep-second-bg)66 !important;

    /* Tabs */
    --tab-selected-bgcolor: var(--deep-highlight) !important;
    --lwt-text-color: var(--deep-foreground) !important;
    --lwt-selected-tab-background-color: var(--deep-highlight) !important;

    /* Toolbar area */
    --toolbarbutton-icon-fill: var(--deep-white) !important;
    --lwt-toolbarbutton-hover-background: var(--deep-active) !important;
    --lwt-toolbarbutton-active-background: var(--deep-highlight) !important;

    /* URL bar */
    --toolbar-field-border-color: var(--deep-border) !important;
    --toolbar-field-focus-border-color: var(--deep-accent) !important;
    --urlbar-popup-url-color: var(--deep-cyan) !important;

    /* URL bar (Firefox < 92) */
    --lwt-toolbar-field-background-color: var(--deep-second-bg) !important;
    --lwt-toolbar-field-focus: var(--deep-highlight) !important;
    --lwt-toolbar-field-color: var(--deep-foreground) !important;
    --lwt-toolbar-field-focus-color: var(--deep-white) !important;

    /* URL bar (Firefox 92+) */
    --toolbar-field-background-color: var(--deep-second-bg) !important;
    --toolbar-field-focus-background-color: var(--deep-highlight) !important;
    --toolbar-field-color: var(--deep-foreground) !important;
    --toolbar-field-focus-color: var(--deep-white) !important;

    /* Sidebar */
    --lwt-sidebar-background-color: var(--deep-second-bg) !important;
    --lwt-sidebar-text-color: var(--deep-foreground) !important;
  }

  /* Line between nav-bar and tabs toolbar */
  #navigator-toolbox { 
    --lwt-tabs-border-color: var(--deep-border) !important; 
  }

  /* Line above tabs */
  #tabbrowser-tabs { 
    --lwt-tab-line-color: var(--deep-accent) !important; 
  }

  /* Sidebar header area */
  #sidebar-box { 
    --sidebar-background-color: var(--deep-second-bg) !important; 
  }
''
