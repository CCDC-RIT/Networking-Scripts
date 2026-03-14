#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Missing argument!"
    exit
fi

download() {
    rm main.zip
    curl -L -O https://github.com/CCDC-RIT/Networking-Scripts/archive/refs/heads/main.zip
    unzip main.zip

    case "$1" in
        pfSense)
            cd Networking-Scripts-main/pfSense || echo "Wrong dir!" && exit
            chmod +x start.sh
            ;;
        palo)
            cd Networking-Scripts-main/palo-alto || echo "Wrong dir!" && exit
            chmod -R +x core
            chmod +x start.sh
            ;;
        cisco)
            echo "TODO"
            ;;
        *)
            echo "Invalid argument!"
            ;;
    esac
}

downloads() {
    download $1
    echo "On your command captain!"
}

downloads $1