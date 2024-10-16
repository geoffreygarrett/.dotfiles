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
  /* Ensure this CSS is applied to the browser chrome */
  @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
  :root {
    --deep-background: #${theme.base00} !important;
    --deep-foreground: #${theme.base05} !important;
    --deep-text: #${theme.base05} !important;
    --deep-selection-bg: #${theme.base02} !important;
    --deep-selection-fg: #${theme.base05} !important;
    --deep-accent: #${theme.base0D} !important;
    --deep-hover: #${theme.base03} !important;
    --deep-active: #${theme.base04} !important;
  }

  /* Global styles */
  * {
    color: var(--deep-text) !important;
    text-shadow: none !important;
  }

  /* Main browser elements */
  #navigator-toolbox,
  #browser,
  #main-window,
  .browser-toolbar {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* URL bar */
  #urlbar,
  #urlbar-background,
  #urlbar-input-container,
  #searchbar {
    background-color: var(--deep-selection-bg) !important;
    color: var(--deep-text) !important;
  }

  #urlbar-input:focus {
    color: var(--deep-text) !important;
  }

  .urlbarView {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  .urlbarView-row:hover {
    background-color: var(--deep-hover) !important;
  }

  /* Tabs */
  .tabbrowser-tab {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  .tabbrowser-tab[selected="true"] {
    background-color: var(--deep-selection-bg) !important;
  }

  .tab-content {
    color: var(--deep-text) !important;
  }

  .tab-background {
    background-color: transparent !important;
  }

  /* Sidebar */
  #sidebar-box,
  #sidebar,
  .sidebar-placesTree {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* Bookmarks */
  #PlacesToolbar,
  #PlacesToolbarItems {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* Context menus */
  menupopup,
  menuitem,
  menu {
    -moz-appearance: none !important;
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  menuitem:hover,
  menu:hover {
    background-color: var(--deep-hover) !important;
  }

  /* Dropdown arrows and icons */
  .urlbar-icon:not([disabled]),
  .toolbarbutton-1:not([disabled]),
  .autocomplete-history-dropmarker,
  .scrollbutton-up,
  .scrollbutton-down {
    fill: var(--deep-text) !important;
  }

  .urlbar-icon:not([disabled]):hover,
  .toolbarbutton-1:not([disabled]):hover {
    background-color: var(--deep-hover) !important;
  }

  /* Autocomplete popup */
  #PopupAutoCompleteRichResult {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  .autocomplete-richlistitem:hover {
    background-color: var(--deep-hover) !important;
  }

  /* Notifications and alerts */
  .notification-message,
  .popup-notification-body,
  #notification-popup {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* Findbar */
  .findbar-container {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* Customization page */
  #customization-container {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* New tab page */
  .newtab-customize-panel {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }

  /* PDF viewer */
  #viewerContainer {
    background-color: var(--deep-background) !important;
  }

  /* ScrollBars */
  scrollbar {
    background-color: var(--deep-background) !important;
  }

  scrollbar thumb {
    background-color: var(--deep-selection-bg) !important;
  }

  /* Ensure all buttons and icons are visible */
  .toolbarbutton-icon,
  .toolbarbutton-badge-stack {
    fill: var(--deep-text) !important;
  }

  /* Force color application to all elements */
  :not(select):not(option) {
    background-color: var(--deep-background) !important;
    color: var(--deep-text) !important;
  }
''
