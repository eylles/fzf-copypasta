#!/bin/sh

# type: string
#   Contains this program's name
myname="${0##*/}"

# type: string file
# definition:
#   "$TMPDIR/copypastas_$$"
#     ^- temp dir       ^- shell pid
tmpfile="${TMPDIR:-/tmp}/copypastas-sh_$$"
# type: pid file
# definition:
#   "$tmpfile.termpid"
#     ^         ^- termpid extension
#     |- temp file name
export pidfile="${tmpfile}.termpid"
#initialize pidfile
:> "$pidfile"

trap 'rm -f -- $pidfile $tmpfile' EXIT

file_print() {
    while read -r line; do
      if ! printf '%s\n' "$line" | grep "TITLE=" >/dev/null; then
        printf '%s\n' "$line"
      fi
    done < "$1"
}

find_alt() {
    for i; do
        command -v "${i%% *}" >/dev/null && {
            printf '%s\n' "$i"
            return 0
        }
        done
    return 1
}

run_float_term() {
    if [ -z "$FLOATING_TERMINAL" ]; then
    # find_alt() prints the first parameter recognized by `command -v`
    FLOATING_TERMINAL=$(find_alt 'foot -a CopyPaster' 'havoc ' 'alacritty --class=CopyPaster -e' \
        'kitty --class=CopyPaster -e' 'konsole -e' 'gnome-terminal -e' 'termite -e' \
        'st -c CopyPaster -e' 'uxterm -name CopyPaster -T CopyPaster -e')
    fi

    $FLOATING_TERMINAL "$@" &
    TERM_PID=$!
    printf '%s\n' "$TERM_PID" > "$pidfile"
}

#config file
CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/copypastas-sh/configrc"
if [ -f "$CONFIG" ]; then
    # load config
    . "$CONFIG"
else
    notify-send "$myname: Error!" "${CONFIG} doesn't exist, example config will be copied"
    if [ ! -d "${XDG_CONFIG_HOME:-${HOME}/.config}/copypastas-sh" ]; then
        mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/copypastas-sh"
    fi
    cp examples-placeholder/configrc "${XDG_CONFIG_HOME:-${HOME}/.config}/copypastas-sh/"
    # load config
    . "$CONFIG"
fi

if [ -z "$PASTAS_DIR" ]; then
    PASTAS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/copypastas-sh"
fi

if [ -d "$PASTAS_DIR" ]; then
    if [ $(find "$PASTAS_DIR" | wc -l) -eq 1 ]; then
        notify-send "$myname: error" "${PASTAS_DIR} empty, it will be populated"
        cp examples-placeholder/gnu+linux "${PASTAS_DIR}/"
    fi
    cd "$PASTAS_DIR" || { printf '%s\n' "$myname: could not cd into $PASTAS_DIR" >&2; exit 1; }
else
    notify-send "$myname: Error!" "${PASTAS_DIR} doesn't exist, it will be created and populated"
    mkdir -p "$PASTAS_DIR"
    cp examples-placeholder/gnu+linux "${PASTAS_DIR}/"
    cd "$PASTAS_DIR" || { printf '%s\n' "$myname: could not cd into $PASTAS_DIR" >&2; exit 1; }
fi

if [ -z "$FZF_PASTA_OPTS" ]; then
    FZF_PASTA_OPTS="--layout=reverse --height 100% --header 'Copy Pastas' \
     --cycle --preview-window sharp --preview-window 70% \
     --prompt='filter: ' \
     --bind alt-k:preview-up \
     --bind alt-j:preview-down"
fi

export FZF_DEFAULT_OPTS="${FZF_PASTA_OPTS} ${FZF_PASTA_COLORS}"

eval $(run_float_term "fzf --preview '@lib@/pasta_preview {}' > $tmpfile") &
until [ -n "$(cat "$pidfile")" ]; do
    sleep .1
done

RUNNING_TERM=$(cat "$pidfile")
while kill -0 "$RUNNING_TERM" 2>/dev/null; do
    sleep 0.4
done

SELECTED_PASTA=$(cat "$tmpfile")

if [ -z "$SELECTED_PASTA" ]; then
    notify-send "$myname" "no file selected"
else
    SELECTED_FILE=$(printf '%s/%s\n' "${PASTAS_DIR}" "${SELECTED_PASTA}")
    case "$XDG_SESSION_TYPE" in
        x11)
            file_print "$SELECTED_FILE" | xclip -selection clipboard
            ;;
        wayland)
            file_print "$SELECTED_FILE" | wl-copy
            ;;
    esac
    notify-send "$myname" "${SELECTED_PASTA} copied to clipboard."
fi
