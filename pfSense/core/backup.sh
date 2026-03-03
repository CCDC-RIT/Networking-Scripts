#!/bin/sh

# Assuming that inventory is run first
BACKUP_DIR="$1"
GUI_SRC="/usr/local/www"
CONFIG_SRC="/conf/config.xml"
RULES_SRC="/tmp/rules.debug"
AUTH_SRC="/etc/inc/auth.inc"
BIN_SRC="/bin"
SBIN_SRC="/sbin"

# Used for debugging
if [ "$#" -ne 1 ]; then
  echo "Missing argument!"
  exit
fi

backup() {
    BACKUP_DIR="$BACKUP_DIR/$(date "+%Y-%m-%d_%H:%M:%S")"
    mkdir "$BACKUP_DIR"
    mkdir "$BACKUP_DIR/bin"
    
    cp -r "$GUI_SRC" "$BACKUP_DIR/www"
    cp "$CONFIG_SRC" "$BACKUP_DIR/config.xml"
    cp "$RULES_SRC" "$BACKUP_DIR/rules.debug"
    cp "$AUTH_SRC" "$BACKUP_DIR/auth.inc"
    cp -r "$BIN_SRC" "$BACKUP_DIR/bin"
    cp -r "$SBIN_SRC" "$BACKUP_DIR/sbin"
}

backup