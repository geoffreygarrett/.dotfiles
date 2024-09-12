{
  config,
  pkgs,
  lib,
  user,
  ...
}:

{
  # Refactored dock configuration
  local.dock = {
    enable = true;
    entries = [
      # Development tools
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "${pkgs.docker}/Applications/Docker.app/"; }

      # Browsers
      { path = "/Applications/Google Chrome.app/"; }

      # Communication
      { path = "/Applications/Slack.app/"; }
      { path = "/System/Applications/Messages.app/"; }
      { path = "/Applications/Zoom.app/"; }

      # Productivity
      { path = "/System/Applications/Calendar.app/"; }
      { path = "/System/Applications/Reminders.app/"; }

      # Utils
      { path = "/Applications/1Password.app/"; }
      { path = "/Applications/TablePlus.app/"; }

      # Folders
      {
        path = "${config.users.users.${user}.home}/Projects";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort date added --view fan --display stack";
      }

      # Shortcuts
      {
        path = "${pkgs.writeShellScriptBin "open-terminal" ''
          ${pkgs.alacritty}/bin/alacritty
        ''}/bin/open-terminal";
        section = "others";
        #        label = "Open Terminal";
      }
      {
        path = "${pkgs.writeShellScriptBin "start-dev-env" ''
          ${pkgs.alacritty}/bin/alacritty -e ${pkgs.zellij}/bin/zellij
        ''}/bin/start-dev-env";
        section = "others";
        #        label = "Start Dev Environment";
      }
      {
        path = "${pkgs.writeShellScriptBin "update-system" ''
          ${pkgs.alacritty}/bin/alacritty -e sh -c "nix flake update && sudo nixos-rebuild switch --flake ."
        ''}/bin/update-system";
        section = "others";
        #        label = "Update System";
      }
    ];
  };
}
