#!/bin/sh

# Assuming that inventory is run first
BACKUP_DIR=""
GUI_SRC="/usr/local/www"
CONFIG_SRC="/conf/config.xml"
RULES_SRC="/tmp/rules.debug"
AUTH_SRC="/etc/inc/auth.inc"

backup() {
    stty -echo
    read -r "Backup directory: " BACKUP_DIR
    stty echo
    echo ""

    cp -r "$GUI_SRC" "$BACKUP_DIR/www"          # GUI PHP files
    cp "$CONFIG_SRC" "$BACKUP_DIR/config.xml"   # Main config file
    cp "$RULES_SRC" "$BACKUP_DIR/rules.debug"   # Debug rules file
    cp "$AUTH_SRC" "$BACKUP_DIR/auth.inc"       # Login check file
}

backup