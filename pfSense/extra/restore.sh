#!/bin/sh

set -eu

REQUEST_NAME="$1"
FILENAME=$(basename "${REQUEST_NAME}")

BASE_URL="https://raw.githubusercontent.com/pfsense/pfsense/RELENG_2_7_2/src/usr/local/www"
URL="$BASE_URL/$FILENAME"

TMPFILE="./${FILENAME}.tmp.$$"
rm -f "$TMPFILE"

if curl -f -s -S -o "$TMPFILE" "$URL"; then
	mv "$TMPFILE" "./${FILENAME}"
	echo "Downloaded ${FILENAME} from ${URL}"
	exit 0
else
	rm -f "$TMPFILE" || true
	echo "Error: failed to download ${URL}" >&2
	exit 1
fi