#!/bin/sh

file_perms() {
    chflags schg /etc/ssh/sshd_config
    chflags schg /etc/rc.initial
    chflags schg /etc/inc/auth.inc
}

remove_suspicious_modules() {
    suspicious_modules=$(tr '\n' ' ' < ../util/info/suspicious_modules.txt)
    for module in $suspicious_modules; do 
        read -p "Do you want to unload the module $module? (y/n)" answer
        answer= $(echo "$answer" | tr '[:upper:]' '[:lower:]')
        if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
            kldunload "$module" 
            echo "Unloaded module: $module"
        else
            echo "Module $module has not been unloaded."
        fi
    done
}

secure() {
    read -p "Do you want to execute file_perms? (y/n)" answer
    answer= $(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        file_perms
        echo "Executing file_perms."
    elif [ "$answer" = "n" ] || [ "$answer" = "no" ]; then
        echo "file_perms has not been executed"
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi

    read -p "Do you want to unload suspicious kernel modules? (y/n)" answer
    answer= $(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        remove_suspicious_modules
    else
        echo "Suspicious modules have not been unloaded."
    fi
}

secure