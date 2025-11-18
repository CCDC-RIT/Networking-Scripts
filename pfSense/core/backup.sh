#!/bin/sh

# Assuming that inventory is run first
BACKUP_DIR="$1"
GUI_SRC="/usr/local/www"
CONFIG_SRC="/conf/config.xml"
RULES_SRC="/tmp/rules.debug"
AUTH_SRC="/etc/inc/auth.inc"

# Used for debugging
if [ "$#" -ne 1 ]; then
  echo "Missing argument!"
  exit
fi

backup() {
    BACKUP_DIR="$BACKUP_DIR/$(date)"
    mkdir "$BACKUP_DIR"
    
    cp -r --parents "$GUI_SRC" "$BACKUP_DIR/www"          # GUI PHP files
    cp --parents "$CONFIG_SRC" "$BACKUP_DIR/config.xml"   # Main config file
    cp --parents "$RULES_SRC" "$BACKUP_DIR/rules.debug"   # Debug rules file
    cp --parents "$AUTH_SRC" "$BACKUP_DIR/auth.inc"       # Login check file
}

backup