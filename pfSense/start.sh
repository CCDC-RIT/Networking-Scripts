#!/bin/sh

setup() {
    echo "#################################################"
    date

    # Create obscure directory to store data
    stty -echo
    read -r "Backup directory: " BACKUP_DIR
    stty echo
    echo ""

    backup "$BACKUP_DIR"
    unset "$BACKUP_DIR"
}

start() {
    cd core || echo "Failed to initialize" && exit
    setup
    sh downloads.sh
    sh inventory.sh
    sh backup.sh
    sh users.sh
    sh audit.sh
    sh secure.sh
    sh firewall.sh
    sh logging.sh
}

start | tee /usr/share/ct/fonts/blueteam/meal.txt
cd ..
