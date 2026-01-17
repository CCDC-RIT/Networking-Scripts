#!/bin/sh

move() {
    case "$1" in
        0)
            if [ -d /usr/local/www ]; then
                mv /usr/local/www /usr/local/wwww
            else
                echo "WARN: GUI MISSING"
            fi
            ;;
        1)
            if [ -d /usr/local/wwww ]; then
                if [ -d /usr/local/www ]; then
                    rm -rf /usr/local/www
                fi
                mv /usr/local/wwww /usr/local/www
                exit
            fi

            # /usr/local/wwww doesn't exist: attempt to restore from BACKUP_DIR
            LATEST_BACKUP=""

            BACKUP_DIR=""
            stty -echo
            read -r BACKUP_DIR
            stty echo

            # Use the first entry inside BACKUP_DIR (dated folder), then expect a 'www' subdir
            first=$(ls -1d "$BACKUP_DIR"/* 2>/dev/null | head -n1)
            if [ -n "$first" ] && [ -d "$first/usr/local/www" ]; then
                LATEST_BACKUP="$first/usr/local/www"
            fi

            if [ -n "$LATEST_BACKUP" ]; then
                echo "Restoring GUI from backup: $LATEST_BACKUP"
                cp -a "$LATEST_BACKUP/www" /usr/local/wwww || { echo "Failed to copy backup from $LATEST_BACKUP"; return 2; }
                
                if [ -d /usr/local/www ]; then
                    mv /usr/local/www /usr/local/www.bak_$(date +%s) 2>/dev/null || rm -rf /usr/local/www
                fi
                mv /usr/local/wwww /usr/local/www
                echo "Restored and moved to /usr/local/www"
                return 0
            else
                echo "No suitable backup found in BACKUP_DIR ($BACKUP_DIR) to restore /usr/local/www"
                return 3
            fi
            ;;
        *)
            echo "Usage: $0 0|1"
            return 4
            ;;
    esac
}

gui() {
    move "$1"
}

gui "$1"