#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Missing argument!"
    exit
fi

if [ "$1" -eq "pfsense" ]; then
    echo "TODO"
elif [ "$1" -eq "palo" ]; then
    echo "TODO"
elif [ "$1" -eq "cisco" ]; then
    echo "TODO"
else
    echo "Invalid argument!"
    exit
fi