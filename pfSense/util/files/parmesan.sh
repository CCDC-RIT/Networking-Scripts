#!/bin/sh

trap '' INT QUIT TERM HUP

LOG_FILE="/var/log/parmesan.log"
INTERVAL=600 #10 minutes
LAST_EXECUTED=0

while true
do
    printf ">"
    read -r input

    now=$(date +%s)
    elapsed=$((now - LAST_EXECUTED))

    case "$input" in
        *'|'*|*';'*|*'&'*|*'`'*|*'$('*|*'>'*|*'<'*)
            echo "Special shell characters are not allowed."
            continue
            ;;
    esac

    set -- $input

    if [ "$#" -gt 2 ]; then
        echo "Too many tokens."
        continue
    fi

    case "$input" in
        echo)
            if [ "$elapsed" -lt "$INTERVAL" ]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                /bin/echo
                LAST_EXECUTED=$now
            fi
            ;;
        echo\ *)
            if [ "$elapsed" -lt "$INTERVAL" ]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                /bin/echo "${input#echo }"
                LAST_EXECUTED=$now
            fi
            ;;
        wall)
            if [ "$elapsed" -lt "$INTERVAL" ]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                /bin/wall
                LAST_EXECUTED=$now
            fi
            ;;
        wall\ *)
            if [ "$elapsed" -lt "$INTERVAL" ]; then
                remaining=$((INTERVAL - elapsed))
                echo "Sorry, please wait $remaining seconds before using wall or echo again. Thanks!"
            else
                printf '%s\n' "${input#wall }" | /usr/bin/wall
                LAST_EXECUTED=$now
            fi
            ;;
        *)
            echo "Unknown command: $input"
            "$input" >> "$LOG_FILE" 2>/dev/null
            ;;
    esac
done
