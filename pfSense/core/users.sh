#!/bin/sh

USERS_REFERENCE="../util/info/users.txt"
ADMINS_REFERENCE="..util/info/admins.txt"

users() {
    while IFS=":" read -r user _ _ _ _ _ shell; do
        if ! grep -qF -x "$user" "/etc/passwd" && ! $shell -ne "/usr/sbin/nologin"; then
            echo "$user not in approved list!"
        fi
    done < "/etc/passwd"
}

users