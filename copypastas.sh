#!/bin/sh

tmpfile="${TMPDIR:-/tmp}/copypastas-sh_$$"
export pidfile="${tmpfile}.termpid"
#initialize pidfile
:> "$pidfile"
trap 'rm -f -- $tmpfile' EXIT
trap 'rm -f -- $pidfile' EXIT

#config file
CONFIG="${XDG_CONFIG_HOME:-~/.config}/copypastas-sh/configrc"
[ -f "$CONFIG" ] && . "$CONFIG"

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

if [ -z "$PASTAS_DIR" ]; then
    PASTAS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/copypastas-sh"
fi

if [ -d "$PASTAS_DIR" ]; then
    if [ $(find "$PASTAS_DIR" | wc -l) -eq 1 ]; then
        notify-send "${0##*/}: error" "${PASTAS_DIR} empty, it will be populated"
        cp examples-placeholder/gnu+linux "${PASTAS_DIR}/"
    fi
    cd "$PASTAS_DIR"
else
    notify-send "${0##*/}: error" "${PASTAS_DIR} doesn't exit, it will be created and populated"
    mkdir -p "$PASTAS_DIR"
    cp examples-placeholder/gnu+linux "${PASTAS_DIR}/"
    cd "$PASTAS_DIR" || { printf '%s\n' "${0##*/}: could not cd into $PASTAS_DIR" >&2; exit 1; }
fi

if [ -z "$FZF_PASTA_OPTS" ]; then
    FZF_PASTA_OPTS="--layout=reverse --height 100% --header 'Copy Pastas' \
     --cycle --preview-window sharp --preview-window 70% \
     --prompt='filter: ' \
     --bind alt-k:preview-up \
     --bind alt-j:preview-down"
fi

export FZF_DEFAULT_OPTS="${FZF_PASTA_OPTS} ${FZF_PASTA_COLORS}"

eval $(run_float_term "fzf --preview 'pasta_preview {}' > $tmpfile") &
until [ -n "$(cat "$pidfile")" ]; do
    sleep .1
done

RUNNING_TERM=$(cat "$pidfile")
while kill -0 "$RUNNING_TERM" 2>/dev/null; do
    sleep 0.4
done

SELECTED_PASTA=$(cat "$tmpfile")

if [ -z "$SELECTED_PASTA" ]; then
    notify-send "${0##*/}" "no file selected"
else
    SELECTED_FILE=$(printf '%s/%s\n' "${PASTAS_DIR}" "${SELECTED_PASTA}")
    file_print "$SELECTED_FILE" | xclip -selection clipboard
    notify-send "${0##*/}" "${SELECTED_PASTA} copied to clipboard."
fi
