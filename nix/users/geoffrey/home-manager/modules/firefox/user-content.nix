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
  /* Deep Ocean Theme for Firefox - User Content */
  :root {
    --deep-background: #${theme.base00};
    --deep-foreground: #${theme.base04};
    --deep-text: #${theme.base03};
    --deep-selection-bg: #717CB480;
    --deep-selection-fg: #${theme.base07};
    --deep-accent: #84FFFF;
  }

  body {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  a {
    color: var(--deep-accent) !important;
  }

  ::selection {
    background: var(--deep-selection-bg) !important;
    color: var(--deep-selection-fg) !important;
  }

  input, textarea {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
    border: 1px solid var(--deep-contrast) !important;
  }
''
