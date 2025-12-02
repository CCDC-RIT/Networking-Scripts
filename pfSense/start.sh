#!/bin/sh

setup() {
    echo "#################################################"
    date

    # Create obscure directory to store data
    stty -echo
    read -r "Backup directory: " BACKUP_DIR
    stty echo
    echo ""

    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"

    sh backup.sh "$BACKUP_DIR"
    unset "$BACKUP_DIR"
}

start() {
    cd core
    setup
    sh inventory.sh
    sh users.sh
    sh audit.sh
    sh secure.sh
    sh firewall.sh
    sh logging.sh
}

start
