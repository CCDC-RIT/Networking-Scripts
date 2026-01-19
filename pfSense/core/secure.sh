#!/bin/sh

file_perms() {
    chflags schg /etc/ssh/sshd_config
    chflags schg /etc/rc.initial
    chflags schg /etc/inc/auth.inc
}

secure() {
    echo "Do you want to execute file_perms? (y/n)"
    read answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ] || [ "$answer" = "yes" ] || [ "$answer" = "YES" ]; then
        file_perms
        echo "Executing file_perms."
    elif [ "$answer" = "n" ] || [ "$answer" = "N" ] || [ "$answer" = "no" ] || [ "$answer" = "NO" ]; then
        echo "file_perms has not been executed"
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
}

secure