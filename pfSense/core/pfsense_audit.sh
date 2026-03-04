#!/bin/sh

DEFAULT_WWW=$(cat ../util/info/default_www.txt)

www() {
    echo "----- WWW -----"
    if [ -d /usr/local/www ]; then
        # shellcheck disable=SC2164
        cd /usr/local/www
        for file in *; do
            [ -e "$file" ] || break

            if ! echo "$DEFAULT_WWW" | grep -q "$file"; then
                echo "Non-default GUI file: $file"
            fi
        done
    fi

    # shellcheck disable=SC2164
    cd /home/root/pfSense/
    echo ""
}

pfsense_audit() {
    www
}

pfsense_audit