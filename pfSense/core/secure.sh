#!/bin/sh

file_perms() {
    chflags schg /etc/ssh/sshd_config
    chflags schg /etc/rc.initial
    chflags schg /etc/inc/auth.inc
}

remove_suspicious_modules() {
    # Resolve the suspicious_modules.txt path relative to this script
    SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
    SUSP_FILE="$SCRIPT_DIR/../util/files/suspicious_modules.txt"
    echo " "

    if [ ! -f "$SUSP_FILE" ]; then
        echo "ERROR: cannot open $SUSP_FILE (No such file or directory)"
        return 1
    fi

    while IFS= read -r module || [ -n "$module" ]; do
        echo "Do you want to unload the module $module? (y/n)"
        read -r answer
        answer="$(echo "$answer" | tr '[:upper:]' '[:lower:]')"

        if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
            if kldunload "$module" >/dev/null 2>&1; then
                echo " "
                echo "Unloaded module: $module"
            else
                echo " "
                echo "Failed to unload module: $module"
            fi
        else
            echo " "
            echo "Module $module has not been unloaded."
        fi
    done < "$SUSP_FILE"
    echo " "
}

secure() {
    echo " "
    echo "Do you want to execute file_perms? (y/n)"
    read -r answer
    answer="$(echo "$answer" | tr '[:upper:]' '[:lower:]')"
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        file_perms
        echo " "
        echo "Executing file_perms."
    elif [ "$answer" = "n" ] || [ "$answer" = "no" ]; then
        echo " "
        echo "file_perms has not been executed"
    else
        echo " "
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
    echo " "

    echo "Do you want to unload suspicious kernel modules? (y/n)"
    read -r answer
    answer="$(echo "$answer" | tr '[:upper:]' '[:lower:]')"
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        remove_suspicious_modules
    else
        echo " "
        echo "Suspicious modules have not been unloaded."
    fi
    echo " "
}

secure