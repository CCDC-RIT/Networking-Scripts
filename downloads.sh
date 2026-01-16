#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Missing argument!"
    exit
fi

download() {
    case "$1" in
        pfSense)
            rm main.zip
            curl -L -O https://github.com/CCDC-RIT/Networking-Scripts/archive/refs/heads/main.zip
            unzip main.zip
            cd Networking-Scripts-main/pfSense
            chmod +x start.sh
            ;;
        palo)
            echo "TODO"
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