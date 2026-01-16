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

docore() {
    cd core
    setup
    sh inventory.sh
    sh users.sh
    sh audit.sh
    sh secure.sh
    sh firewall.sh
    sh logging.sh
}

restore() {
    cd extra
    sh restore.sh $2 $3
}

gui() {
    cd extra
    sh gui.sh
}

start() {
    if [ "$#" -eq 0 ]; then {
        docore
    } else if [ "$1" -eq "restore" ]; then {
        restore
    } else if [ "$1" -eq "gui" ]; then {
        gui
    } fi
}

start