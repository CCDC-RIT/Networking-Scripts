#!/bin/sh

setup() {
    echo "#################################################"
    date

    # Create obscure directory to store data
    if [ ! -d /usr/share/vt/fonts/blueteam ]; then
        mkdir -p /usr/share/vt/fonts/blueteam
    fi
}

serve() {
    cd core || echo "Failed to initialize" && exit
    setup
    # sh downloads.sh
    sh inventory.sh
    sh backup.sh
    sh users.sh
    sh audit.sh
    # sh secure.sh
    # sh firewall.sh
    # sh logging.sh
}

serve | tee /usr/share/ct/fonts/blueteam/meal.txt
cd ..
