#!/bin/sh

trap '' INT QUIT TERM HUP

LOG_FILE="/var/log/sharp_cheddar.log"
INTERVAL=600 #10 minutes
LAST_EXECUTED=0

while true
do
    printf ">"
    read -r input

    now=$(date +%s)
    elapsed=$((now - LAST_EXECUTED))

    case "$input" in
        echo*)
            if ["$elpased" -lt "$INTERVAL"]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                /bin/echo "${input#echo }"
                LAST_EXECUTED=$now
            fi
            ;;
        wall*)
             if ["$elpased" -lt "$INTERVAL"]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                /usr/bin/wall "${input#wall }"
                LAST_EXECUTED=$now
            fi
            ;;
        *)
            echo "Unknown command: $input"
            $input >> "$LOG_FILE" 2>&1
            ;;
    esac
done
