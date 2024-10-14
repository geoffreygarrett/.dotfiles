{ pkgs }:

let
  rofiConfig = ./rofi;

  updatesScript = pkgs.writeShellScriptBin "polybar-updates" ''
    NOTIFY_ICON="${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-software-update.svg"

    get_total_updates() { UPDATES=$(${pkgs.pacman}/bin/checkupdates 2>/dev/null | wc -l); }

    while true; do
        get_total_updates

        if hash notify-send &>/dev/null; then
            if (( UPDATES > 50 )); then
                ${pkgs.libnotify}/bin/notify-send -u critical -i "$NOTIFY_ICON" \
                    "You really need to update!!" "$UPDATES New packages"
            elif (( UPDATES > 25 )); then
                ${pkgs.libnotify}/bin/notify-send -u normal -i "$NOTIFY_ICON" \
                    "You should update soon" "$UPDATES New packages"
            elif (( UPDATES > 2 )); then
                ${pkgs.libnotify}/bin/notify-send -u low -i "$NOTIFY_ICON" \
                    "$UPDATES New packages"
            fi
        fi

        while (( UPDATES > 0 )); do
            echo "$UPDATES"
            sleep 10
            get_total_updates
        done

        while (( UPDATES == 0 )); do
            echo "None"
            sleep 1800
            get_total_updates
        done
    done
  '';

  launcherScript = pkgs.writeShellScriptBin "polybar-launcher" ''
    ${pkgs.rofi}/bin/rofi -no-config -no-lazy-grab -show drun -modi drun -theme ${rofiConfig}/launcher.rasi
  '';

  styleSwitchScript = pkgs.writeShellScriptBin "polybar-style-switch" ''
    SDIR="${rofiConfig}"

    MENU="$(${pkgs.rofi}/bin/rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p "" \
    -theme "$SDIR/styles.rasi" \
    <<< " Default| Nord| Gruvbox| Dark| Cherry|")"
    case "$MENU" in
        *Default) ${pkgs.bash}/bin/bash "$SDIR/styles.sh" --default ;;
        *Nord) ${pkgs.bash}/bin/bash "$SDIR/styles.sh" --nord ;;
        *Gruvbox) ${pkgs.bash}/bin/bash "$SDIR/styles.sh" --gruvbox ;;
        *Dark) ${pkgs.bash}/bin/bash "$SDIR/styles.sh" --dark ;;
        *Cherry) ${pkgs.bash}/bin/bash "$SDIR/styles.sh" --cherry ;;
    esac
  '';

  powermenuScript = pkgs.writeShellScriptBin "polybar-powermenu" ''
    dir="${rofiConfig}"
    uptime=$(${pkgs.coreutils}/bin/uptime -p | ${pkgs.gnused}/bin/sed -e 's/up //g')

    rofi_command="${pkgs.rofi}/bin/rofi -no-config -theme ${rofiConfig}/powermenu.rasi"

    shutdown=" Shutdown"
    reboot=" Restart"
    lock=" Lock"
    suspend=" Sleep"
    logout=" Logout"

    confirm_exit() {
        ${pkgs.rofi}/bin/rofi -dmenu \
        -no-config \
        -i \
        -no-fixed-num-lines \
        -p "Are You Sure? : " \
        -theme "$dir/confirm.rasi"
    }

    msg() {
        ${pkgs.rofi}/bin/rofi -no-config -theme "${rofiConfig}/message.rasi" -e "Available Options  -  yes / y / no / n"
    }

    options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

    chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
    case $chosen in
        $shutdown)
            ans=$(confirm_exit)
            if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
                ${pkgs.systemd}/bin/systemctl poweroff
            elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
                exit 0
            else
                msg
            fi
            ;;
        $reboot)
            ans=$(confirm_exit)
            if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
                ${pkgs.systemd}/bin/systemctl reboot
            elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
                exit 0
            else
                msg
            fi
            ;;
        $lock)
            if [[ -f ${pkgs.i3lock}/bin/i3lock ]]; then
                ${pkgs.i3lock}/bin/i3lock
            elif [[ -f ${pkgs.betterlockscreen}/bin/betterlockscreen ]]; then
                ${pkgs.betterlockscreen}/bin/betterlockscreen -l
            fi
            ;;
        $suspend)
            ans=$(confirm_exit)
            if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
                ${pkgs.mpc_cli}/bin/mpc -q pause
                ${pkgs.alsa-utils}/bin/amixer set Master mute
                ${pkgs.systemd}/bin/systemctl suspend
            elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
                exit 0
            else
                msg
            fi
            ;;
        $logout)
            ans=$(confirm_exit)
            if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
                if [[ "$DESKTOP_SESSION" == "Openbox" ]]; then
                    ${pkgs.openbox}/bin/openbox --exit
                elif [[ "$DESKTOP_SESSION" == "bspwm" ]]; then
                    ${pkgs.bspwm}/bin/bspc quit
                elif [[ "$DESKTOP_SESSION" == "i3" ]]; then
                    ${pkgs.i3}/bin/i3-msg exit
                fi
            elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
                exit 0
            else
                msg
            fi
            ;;
    esac
  '';
in
{
  inherit
    updatesScript
    launcherScript
    styleSwitchScript
    powermenuScript
    ;
}
