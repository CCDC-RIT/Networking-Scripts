#!/bin/sh

move() {
    stty -echo
    read -r WEB_DIR
    stty echo
    echo ""

    if [ -d /usr/local/www ]; then
        mv /usr/local/www/*.php /usr/local/www/"$WEB_DIR"/
    else
        echo "[WARN]: GUI files missing!"
    fi
}

gui() {
    move
}

gui