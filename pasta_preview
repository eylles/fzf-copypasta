#!/bin/sh
pretty_print() {
    printf '\n%s %s\n\n' "Title: " "$1"
    while IFS= read -r REPLY; do
      if ! printf '%s\n' "$REPLY" | grep "TITLE=" >/dev/null; then
        printf '%s\n' "$REPLY"
      fi
    done
}

margin_print() {
    while IFS= read -r REPLY; do
        printf '%s%s\n' "$1" "$REPLY"
    done
}

read_file() {
  if [ $# -gt 1 ]; then
    prefix=$2
  else
    prefix=""
  fi
  while read -r FileLine
  do
    printf '%s%s\n' "$prefix" "$FileLine"
  done < "$1"
}

pasta_preview() {
    file=$1
    titleVar=$(grep -i title "$file")
    read_file "$file" | pretty_print "${titleVar#TITLE=}" | fold -s -w $(( FZF_PREVIEW_COLUMNS - 4 )) | margin_print "  "
}

if [ -f "$1" ]; then
  pasta_preview "$1"
else
  printf '%s\n' "${0##*/}: invalid argument $1"
fi
