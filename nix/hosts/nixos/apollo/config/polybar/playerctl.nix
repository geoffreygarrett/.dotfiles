{ pkgs, lib, ... }:
{
  "module/playerctl" = {
    type = "custom/script";
    exec =
      let
        script = pkgs.writeShellScriptBin "playerctl-status" ''
          # Function to get player status
          get_status() {
              playerctl -a metadata --format '{{status}}' 2>/dev/null | head -n1
          }
          # Function to get current track info
          get_track_info() {
              playerctl -a metadata --format '{{playerName}}:{{artist}} - {{title}}' 2>/dev/null | head -n1
          }
          # Function to replace player names with icons
          replace_player_name() {
              sed -E 's/spotify/󰓇/; s/firefox/󰈹/; s/chromium/󰊯/; s/mpv/󰐊/; s/^([^:]+):/\1 /'
          }
          # Main logic
          status=$(get_status)
          track_info=$(get_track_info | replace_player_name)
          case $status in
              Playing)
                  echo " $track_info"
                  ;;
              Paused)
                  echo "󰏤 $track_info"
                  ;;
              *)
                  echo "󰓃 No media"
                  ;;
          esac
        '';
      in
      "${script}/bin/playerctl-status";
    interval = 1;
    format = "<label>";
    label = "%output:0:50:...%";
    format-foreground = colors.foreground;
    click-left = "${pkgs.playerctl}/bin/playerctl play-pause";
    click-right = "${pkgs.playerctl}/bin/playerctl next";
    click-middle = "${pkgs.playerctl}/bin/playerctl previous";
  };
}
