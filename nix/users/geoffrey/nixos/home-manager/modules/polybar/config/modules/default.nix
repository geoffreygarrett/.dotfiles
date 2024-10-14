{
  pkgs,
  lib,
  config,
  base16,
  ...
}@args:

let
  brightness-control = import ./scripts/brightness-control.nix { inherit pkgs; };
in
(import ./user-modules.nix args)
// {
  "module/tray" = {
    type = "internal/tray";
    padding = 2;
    background = "#${base16.base00}";
    foreground = "#${base16.base05}";
    icon-size = 16;
  };
  "module/bspwm" = {
    type = "internal/bspwm";
    label-focused = "%name%";
    label-focused-background = "#${base16.base02}";
    label-focused-underline = "#${base16.base0D}";
    label-focused-padding = 2;
    label-occupied = "%name%";
    label-occupied-padding = 2;
    label-urgent = "%name%";
    label-urgent-background = "#${base16.base08}";
    label-urgent-padding = 2;
    label-empty = "%name%";
    label-empty-foreground = "#${base16.base03}";
    label-empty-padding = 2;
  };
  "module/xwindow" = {
    type = "internal/xwindow";
    label = "%title:0:60:...%";
  };
  "module/date" = {
    type = "internal/date";
    interval = 5;
    date = "%Y-%m-%d";
    time = "%H:%M";
    label = "%date% %time%";
    format-prefix = "󰃰 ";
    format-prefix-foreground = "#${base16.base0D}";
  };
  "module/pulseaudio" = {
    type = "internal/pulseaudio";
    format-volume = "<ramp-volume> <label-volume>";
    label-volume = "%percentage%%";
    label-muted = "󰝟 muted";
    ramp-volume-0 = "󰕿";
    ramp-volume-1 = "󰖀";
    ramp-volume-2 = "󰕾";
    ramp-volume-foreground = "#${base16.base0D}";
  };
  "module/memory" = {
    type = "internal/memory";
    interval = 5;
    format-prefix = "󰍛 ";
    format-prefix-foreground = "#${base16.base0D}";
    label = "%percentage_used:2%%";
  };
  "module/cpu" = {
    type = "internal/cpu";
    interval = 5;
    format-prefix = "󰻠 ";
    format-prefix-foreground = "#${base16.base0D}";
    label = "%percentage:2%%";
  };
  "module/brightness" = {
    type = "custom/script";
    exec = "${pkgs.coreutils}/bin/cat $HOME/.polybar-brightness";
    hook-0 = "${pkgs.coreutils}/bin/cat $HOME/.polybar-brightness";
    format = "<label>";
    label = "%output%";
    format-foreground = "#${base16.base05}";
    scroll-up = "${brightness-control}/bin/brightness-control up";
    scroll-down = "${brightness-control}/bin/brightness-control down";
    click-left = "${brightness-control}/bin/brightness-control up";
    click-right = "${brightness-control}/bin/brightness-control down";
  };
  "module/spotify" = {
    type = "custom/script";
    exec =
      let
        script = pkgs.writeShellScriptBin "scroll_spotify_status" ''
          #!/usr/bin/env bash
          # Fetch the current status and track info from Spotify
          status=$(${pkgs.playerctl}/bin/playerctl -p spotify status 2>/dev/null || echo "No player")
          if [ "$status" = "No player" ]; then
            echo "󰓃 No media"
            exit 0
          fi
          track_info=$(${pkgs.playerctl}/bin/playerctl -p spotify metadata --format '{{artist}} - {{title}}' 2>/dev/null || echo "No media")
          # Handle edge case: when there's no track info
          if [ -z "$track_info" ] || [ "$track_info" = "No media" ]; then
            track_info="No media"
          fi
          # Update the output based on the current status
          case $status in
            Playing)
              icon="󰓇"
              ;;
            Paused)
              icon="󰏤"
              ;;
            *)
              icon="󰓃"
              ;;
          esac
          # Output the result directly
          echo "$icon $track_info"
        '';
      in
      "${script}/bin/scroll_spotify_status";
    format = "<label>";
    label = "%output%";
    format-foreground = "#${base16.base05}";
    interval = 2;
  };
  "module/spotify-volume" = {
    type = "custom/script";
    exec =
      let
        script = pkgs.writeShellScriptBin "spotify_volume" ''
          VOLUME=$(${pkgs.playerctl}/bin/playerctl -p spotify volume 2>/dev/null || echo "N/A")
          if [ "$VOLUME" != "N/A" ]; then
            VOLUME_PERCENT=$(printf "%.0f" $(echo "$VOLUME * 100" | ${pkgs.bc}/bin/bc))
            echo "󰕾 $VOLUME_PERCENT%"
          else
            echo "󰕾 N/A"
          fi
        '';
      in
      "${script}/bin/spotify_volume";
    label = "%output%";
    format = "<label>";
    format-foreground = "#${base16.base05}";
    interval = 1;
    click-left = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05+";
    click-right = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05-";
    scroll-up = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05+";
    scroll-down = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05-";
  };
  "module/spotify-prev" = {
    type = "custom/script";
    exec = "echo '󰒮'";
    label = "%output%";
    format = "<label>";
    format-foreground = "#${base16.base0D}";
    click-left = "${pkgs.playerctl}/bin/playerctl previous -p spotify";
  };
  "module/spotify-play-pause" = {
    type = "custom/script";
    interval = 1;
    exec =
      let
        play_pause_script = pkgs.writeShellScriptBin "spotify_play_pause_status" ''
          status=$(playerctl -p spotify status 2>/dev/null)
          if [ "$status" = "Playing" ]; then
            echo "󰐊" 
          elif [ "$status" = "Paused" ]; then
            echo "󰏤" 
          else
            echo "󰓃" 
          fi
        '';
      in
      "${play_pause_script}/bin/spotify_play_pause_status";
    label = "%output%";
    format = "<label>";
    format-foreground = "#${base16.base0D}";
    click-left = "${pkgs.playerctl}/bin/playerctl play-pause -p spotify";
  };
  "module/spotify-next" = {
    type = "custom/script";
    exec = "echo '󰒭'";
    label = "%output%";
    format = "<label>";
    format-foreground = "#${base16.base0D}";
    click-left = "${pkgs.playerctl}/bin/playerctl next -p spotify";
  };
}
