#!/bin/sh

setup() {
    echo "#################################################"
    date

    # shellcheck disable=SC2164
    cd core

    stty -echo
    read -r BACKUP_DIR
    stty echo
    echo ""

    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"

    sh backup.sh "$BACKUP_DIR"
    unset "$BACKUP_DIR"
}

core() {
    setup
    sh inventory.sh
    sh users.sh
    sh freebsd_audit.sh
    sh pfsense_audit.sh
    sh secure.sh
    sh firewall.sh
    sh logging.sh
}

restore() {
    # shellcheck disable=SC2164
    cd extra
    sh restore.sh "$1"
}

gui() {
    # shellcheck disable=SC2164
    cd extra
    sh gui.sh
}

start() {
    if [ "$#" -eq 0 ]; then 
        core
        exit
    fi

    case "$1" in
        restore) restore "$2";;
        gui) gui;;
        backup) setup;;
        *) echo "Invalid start parameter!";;
    esac
}

start "$@"