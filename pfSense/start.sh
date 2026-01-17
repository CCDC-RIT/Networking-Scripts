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

core() {
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
    sh restore.sh "$2"
}

gui() {
    echo "DO NOT USE"
    # cd extra
    # sh gui.sh
}

start() {
    if [ "$#" -eq 0 ]; then 
        core
    fi

    case "$1" in
        restore) restore "$2";;
        gui) gui;;
        backup) setup;;
        *) echo "Invalid parameter!";;
    esac
}

start "$@"