{
  self,
  inputs,
  config,
  lib,
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared/cachix
    ../../modules/darwin
  ];

  services.nix-daemon.enable = true;

  # Environment packages
  environment.systemPackages =
    with pkgs;
    [
      pkgs.nushell
    ]
    ++ (import ../../modules/shared/packages { inherit pkgs; });

  # Placeholder for host-specific configurations
  # ...

  # Commented out sections for future reference or customization
  # launchd.user.agents.emacs = {
  #   path = [ config.environment.systemPath ];
  #   serviceConfig = {
  #     KeepAlive = true;
  #     ProgramArguments = [
  #       "/bin/sh"
  #       "-c"
  #       "{ osascript -e 'display notification \"Attempting to start Emacs...\" with title \"Emacs Launch\"'; /bin/wait4path ${pkgs.emacs}/bin/emacs && { ${pkgs.emacs}/bin/emacs --fg-daemon; if [ $? -eq 0 ]; then osascript -e 'display notification \"Emacs has started.\" with title \"Emacs Launch\"'; else osascript -e 'display notification \"Failed to start Emacs.\" with title \"Emacs Launch\"' >&2; fi; } } &> /tmp/emacs_launch.log"
  #     ];
  #     StandardErrorPath = "/tmp/emacs.err.log";
  #     StandardOutPath = "/tmp/emacs.out.log";
  #   };
  # };
}
