#!/bin/sh

trap '' INT QUIT TERM HUP

while true
do
    printf ">"
    read -r input

    case "$input" in
        echo*)
            /bin/echo "${input#echo }"
            ;;
        wall*)
            /usr/bin/wall "${input#wall }"
            ;;
        *)
            echo "Unknown command: $input"
            ;;
    esac
done
