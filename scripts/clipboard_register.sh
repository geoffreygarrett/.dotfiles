##!/usr/bin/env bash
#
## Configuration
#CLIPBOARD_PORT=8877
#CLIPBOARD_DIR="$HOME/.clipboards"
#PIDFILE="/tmp/clipboard_server.pid"
#
## Ensure clipboard directory exists
#mkdir -p "$CLIPBOARD_DIR"
#
## Neovim-inspired register types
#UNNAMED_REG='"'
#SMALL_DELETE_REG='-'
#NUMBERED_REGS=(0 1 2 3 4 5 6 7 8 9)
#NAMED_REGS=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
#READONLY_REGS=('.' '%' ':' '#')
#
## Function to use netcat in a cross-platform way
#nc_wrapper() {
#    if [ "$(uname)" == "Darwin" ]; then
#        # macOS version
#        nc "$@"
#    else
#        # Linux version
#        nc -q 1 "$@"
#    fi
#}
#
## Function to start clipboard server
#start_server() {
#    if [ -f "$PIDFILE" ]; then
#        if kill -0 $(cat "$PIDFILE") 2>/dev/null; then
#            echo "Server is already running."
#            return
#        else
#            rm "$PIDFILE"
#        fi
#    fi
#
#    (
#        while true; do
#            nc -l $CLIPBOARD_PORT | while read cmd register content; do
#                case "$cmd" in
#                    SET)
#                        case "$register" in
#                            $UNNAMED_REG)
#                                echo "$content" > "$CLIPBOARD_DIR/$register"
#                                for ((i=8; i>=0; i--)); do
#                                    mv "$CLIPBOARD_DIR/${NUMBERED_REGS[$i]}" "$CLIPBOARD_DIR/${NUMBERED_REGS[$i+1]}" 2>/dev/null
#                                done
#                                cp "$CLIPBOARD_DIR/$UNNAMED_REG" "$CLIPBOARD_DIR/${NUMBERED_REGS[0]}" 2>/dev/null
#                                ;;
#                            $SMALL_DELETE_REG)
#                                echo "$content" > "$CLIPBOARD_DIR/$register"
#                                ;;
#                            [0-9])
#                                echo "READ_ONLY" | nc_wrapper localhost $CLIPBOARD_PORT
#                                continue
#                                ;;
#                            [a-z])
#                                echo "$content" > "$CLIPBOARD_DIR/$register"
#                                ;;
#                            *)
#                                # shellcheck disable=SC2199
#                                # shellcheck disable=SC2076
#                                if [[ " ${READONLY_REGS[@]} " =~ " ${register} " ]]; then
#                                    echo "READ_ONLY" | nc_wrapper localhost $CLIPBOARD_PORT
#                                    continue
#                                fi
#                                ;;
#                        esac
#                        echo "SET $register" | nc_wrapper localhost $CLIPBOARD_PORT
#                        ;;
#                    GET)
#                        if [ -f "$CLIPBOARD_DIR/$register" ]; then
#                            # shellcheck disable=SC2002
#                            cat "$CLIPBOARD_DIR/$register" | nc_wrapper localhost $CLIPBOARD_PORT
#                        else
#                            echo "EMPTY" | nc_wrapper localhost $CLIPBOARD_PORT
#                        fi
#                        ;;
#                    LIST)
#                        (
#                            echo "Unnamed: $(cat "$CLIPBOARD_DIR/$UNNAMED_REG" 2>/dev/null)"
#                            echo "Small delete: $(cat "$CLIPBOARD_DIR/$SMALL_DELETE_REG" 2>/dev/null)"
#                            echo "Numbered:"
#                            for reg in "${NUMBERED_REGS[@]}"; do
#                                echo "  $reg: $(head -n 1 "$CLIPBOARD_DIR/$reg" 2>/dev/null)"
#                            done
#                            echo "Named:"
#                            for reg in "${NAMED_REGS[@]}"; do
#                                content=$(head -n 1 "$CLIPBOARD_DIR/$reg" 2>/dev/null)
#                                if [ ! -z "$content" ]; then
#                                    echo "  $reg: $content"
#                                fi
#                            done
#                        ) | nc_wrapper localhost $CLIPBOARD_PORT
#                            ;;
#                    esac
#                done
#            done
#        ) &
#
#        echo $! > "$PIDFILE"
#        echo "Server started with PID $(cat "$PIDFILE")"
#    }
#
#    ensure_server_running() {
#        if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE") 2>/dev/null; then
#            start_server
#            sleep 1  # Give the server a moment to start
#        fi
#    }
#
#    # Function to set clipboard content
#    set_clipboard() {
#        ensure_server_running
#        register="$1"
#        content="$2"
#        result=$(echo "SET $register $content" | nc_wrapper localhost $CLIPBOARD_PORT)
#        if [ "$result" = "READ_ONLY" ]; then
#            echo "Cannot write to read-only register '$register'."
#        else
#            echo "Content set in register '$register'."
#        fi
#    }
#
#    # Function to get clipboard content
#    get_clipboard() {
#        ensure_server_running
#        register="$1"
#        result=$(echo "GET $register" | nc_wrapper localhost $CLIPBOARD_PORT)
#        if [ "$result" = "EMPTY" ]; then
#            echo "Register '$register' is empty."
#        else
#            echo "$result"
#        fi
#    }
#
#    # Function to list all registers
#    list_clipboards() {
#        ensure_server_running
#        echo "LIST" | nc_wrapper localhost $CLIPBOARD_PORT
#    }
#
#    # Function to show all registers
#    show_all_registers() {
#        ensure_server_running
#        {
#            printf "=== Clipboard Registers ===\n"
#            printf "Unnamed (\"):\t%s\n" "$(cat "$CLIPBOARD_DIR/$UNNAMED_REG" 2>/dev/null)"
#            printf "Small Delete (-):\t%s\n" "$(cat "$CLIPBOARD_DIR/$SMALL_DELETE_REG" 2>/dev/null)"
#
#            printf "\nNumbered Registers:\n"
#            for reg in "${NUMBERED_REGS[@]}"; do
#                content=$(head -n 1 "$CLIPBOARD_DIR/$reg" 2>/dev/null)
#                printf "%d:\t%s\n" "$reg" "$content"
#            done
#
#            printf "\nNamed Registers:\n"
#            for reg in "${NAMED_REGS[@]}"; do
#                content=$(head -n 1 "$CLIPBOARD_DIR/$reg" 2>/dev/null)
#                if [ -n "$content" ]; then
#                    printf "%s:\t%s\n" "$reg" "$content"
#                fi
#            done
#
#            printf "\nRead-only Registers:\n"
#            for reg in "${READONLY_REGS[@]}"; do
#                content=$(head -n 1 "$CLIPBOARD_DIR/$reg" 2>/dev/null)
#                printf "%s:\t%s\n" "$reg" "$content"
#            done
#        } | less
#    }
#
#    # Main logic
#    case "$1" in
#        server)
#            start_server
#            ;;
#        set)
#            if [ -z "$2" ] || [ -z "$3" ]; then
#                printf "Usage: %s set <register> <content>\n" "$0"
#                exit 1
#            fi
#            set_clipboard "$2" "$3"
#            ;;
#        get)
#            if [ -z "$2" ]; then
#                printf "Usage: %s get <register>\n" "$0"
#                exit 1
#            fi
#            get_clipboard "$2"
#            ;;
#        list)
#            list_clipboards
#            ;;
#        show)
#            show_all_registers
#            ;;
#        *)
#            printf "Usage: %s {server | set <register> <content> | get <register> | list | show}\n" "$0"
#            exit 1
#            ;;
#    esac