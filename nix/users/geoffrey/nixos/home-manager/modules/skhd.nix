{ pkgs, ... }:
let
  brightness-control = import ../scripts/brightness-control.nix { inherit pkgs; };
in
{
  services.sxhkd = {
    enable = true;
    keybindings = {
      # Basic controls
      "super + Return" = "alacritty";
      "super + @space" = "rofi -show drun";
      "super + Escape" = "pkill -USR1 -x sxhkd";
      "super + alt + {q,r}" = "bspc {quit,wm -r}";
      "super + {_,shift + }w" = "bspc node -{c,k}";

      # State/flags
      "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
      "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

      # Focus/swap
      "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";
      "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";
      "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window";
      "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local";
      "super + {grave,Tab}" = "bspc {node,desktop} -f last";

      # Preselect
      "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";
      "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";
      "super + ctrl + space" = "bspc node -p cancel";

      # Move/resize
      "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
      "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

      # Desktop management
      "super + {1-3}" = "bspc desktop -f 'DP-4:^{1-3}'";
      "super + {4-6}" = "bspc desktop -f 'HDMI-1:^{1-3}'";
      "super + shift + {1-3}" = "bspc node -d 'DP-4:^{1-3}'";
      "super + shift + {4-6}" = "bspc node -d 'HDMI-1:^{1-3}'";

      # Monitor focus
      "super + backslash" = "bspc monitor -f next";

      # Move node to next monitor
      "super + shift + backslash" = "bspc node -m next --follow";

      # Advanced window management
      "super + {_,shift + }n" = "bspc node -f {next,prev}.local";
      "super + {_,shift + }m" = "bspc desktop -l {next,prev}";
      "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";
      "super + g" = "bspc node -s biggest.window";

      # Scratchpad (requires additional setup)
      "super + minus" = "scratchpad";
      "super + shift + minus" = "scratchpad -m";

      # Volume control
      "XF86Audio{RaiseVolume,LowerVolume,Mute}" = "pactl set-sink-{volume @DEFAULT_SINK@ {+,-}5%,mute @DEFAULT_SINK@ toggle}";

      # Brightness control
      "XF86MonBrightnessUp" = "${brightness-control}/bin/brightness-control up";
      "XF86MonBrightnessDown" = "${brightness-control}/bin/brightness-control down";

      # Screenshot
      "Print" = "maim -s | xclip -selection clipboard -t image/png";
      "shift + Print" = "maim | xclip -selection clipboard -t image/png";

      # Application shortcuts
      "super + e" = "nautilus";
      "super + b" = "firefox";

      # Polybar
      "super + p" = "polybar-msg cmd toggle";
      "super + shift + p" = "killall polybar; polybar main &";

      # Media control
      "XF86AudioPlay" = "playerctl play-pause";
      "XF86AudioNext" = "playerctl next";
      "XF86AudioPrev" = "playerctl previous";

      # Volume control
      "XF86AudioRaiseVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      "XF86AudioLowerVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "XF86AudioMute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
  };
}
