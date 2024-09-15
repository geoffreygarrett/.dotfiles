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
    #    ../../modules/nixos
    #    ../../modules/nixos/home-manager.nix
    ../../modules/shared
    #    ../../modules/shared/cachix
    #./configuration.nix
  ];

  #  services.nix-daemon.enable = true;

  # Environment packages
  environment.systemPackages =
    with pkgs;
    [ ] ++ (import ../../modules/shared/packages { inherit pkgs; });

  #  environment.sessionVariables = {
  #    EDITOR = "nvim";
  #    VISUAL = "nvim";
  #    PAGER = "less";
  #    LESS = "-R";
  #    LESSOPEN = "| $(which lesspipe.sh) %s";
  #    LESSCLOSE = "kill %s";
  #    LESS_TERMCAP_mb = "\e[1;31m";
  #    LESS_TERMCAP_md = "\e[1;31m";
  #    LESS_TERMCAP_me = "\e[0m";
  #    LESS_TERMCAP_se = "\e[0m";
  #    LESS_TERMCAP_so = "\e[1;44;33m";
  #    LESS_TERMCAP_ue = "\e[0m";
  #    LESS_TERMCAP_us = "\e[1;32m";
  #  };

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
