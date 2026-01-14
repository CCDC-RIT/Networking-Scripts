#!/bin/sh

set -eu

KEY=$1
OUTFILE=$2
RESTORE_LIST="../util/info/restore_files.txt"
FILENAME=""
REPO_PATH=""

while IFS= read -r line || [ -n "$line" ]; do
	# trim
	line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
	[ -z "$line" ] && continue
	case "$line" in
		\#*) continue ;; # skip comments
	esac
	# split on first ':' to allow ':' in paths after the first
	filename_part=$(printf "%s" "$line" | cut -d':' -f1)
	repo_part=$(printf "%s" "$line" | cut -d':' -f2-)
	keyname=$(echo "$filename_part" | sed 's/\.php$//')
	if [ "$keyname" = "$KEY" ]; then
		FILENAME="$filename_part"
		REPO_PATH="$repo_part"
		break
	fi
done < "$RESTORE_LIST"

if [ -z "$REPO_PATH" ]; then
	echo "Error: key '$KEY' not listed in $RESTORE_LIST" >&2
	exit 1
fi

BASE_URL="https://raw.githubusercontent.com/pfsense/pfsense/pfsense-2.7.2"
PATHS=("$REPO_PATH")

tmpfile="${OUTFILE}.tmp.$$"
rm -f "$tmpfile"

for p in "${PATHS[@]}"; do
	url="$BASE_URL/$p"
	# Try to fetch and check HTTP status
	http_code=$(curl -s -w "%{http_code}" -o "${tmpfile}.body" "$url" || true)
	if [ "$http_code" = "200" ] && [ -s "${tmpfile}.body" ]; then
		# write header mapping: filename:repo_path
		echo "$FILENAME:$p" > "$tmpfile"
		cat "${tmpfile}.body" >> "$tmpfile"
		mv "$tmpfile" "$OUTFILE"
		rm -f "${tmpfile}.body"
		echo "Downloaded $KEY -> $OUTFILE (from $url)"
		exit 0
	else
		rm -f "${tmpfile}.body" || true
	fi
done