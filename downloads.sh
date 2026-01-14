#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Missing argument!"
    exit
fi

download() {
    if [ "$1" -eq "pfsense" ]; then
        rm main.zip
        curl -L -O https://github.com/CCDC-RIT/Networking-Scripts/archive/refs/heads/main.zip
        unzip main.zip
        cd Networking-Scripts-main/pfSense
        chmod +x start.sh
    elif [ "$1" -eq "palo" ]; then
        echo "TODO"
    elif [ "$1" -eq "cisco" ]; then
        echo "TODO"
    else
        echo "Invalid argument!"
        exit
    fi
}

downloads() {
    download
    echo "On your command captain!"
}

downloads