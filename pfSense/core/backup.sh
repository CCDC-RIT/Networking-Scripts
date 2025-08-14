#!/bin/sh

# Assuming that inventory is run first
BACKUP_DIR="/usr/share/vt/fonts/blueteam"
GUI_SRC="/usr/local/www"
CONFIG_SRC="/cf/conf/config.xml"

backup() {
    cp -r "$GUI_SRC" "$BACKUP_DIR/www"          # GUI PHP files
    cp "$CONFIG_SRC" "$BACKUP_DIR/config.xml"   # main config file
}

backup