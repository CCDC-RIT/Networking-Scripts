#!/bin/sh

setup() {
    echo "#################################################"
    date

    stty -echo
    read -r BACKUP_DIR
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
    if [ "$#" -eq 0 ]; then 
        docore
    elif [ "$1" -eq "restore" ]; then
        restore
    elif [ "$1" -eq "gui" ]; then
        gui
    else
        echo "Invalid parameter!"
    fi
}

start