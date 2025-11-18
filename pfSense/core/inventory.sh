#!/bin/sh

# List all users
users() {
    ADMIN_GROUP="#####admins#####"
    ADMIN_USERS=$(grep "^$ADMIN_GROUP:" /etc/group | cut -d: -f4 | tr ',' '\n')

    echo "Users:"
    while IFS=: read -r username _ uid _ _ home _; do
        if [ "$uid" -ge 1000 ]; then
            output="$username"
            # Check for admin perms
            if echo "$ADMIN_USERS" | grep -qw "$username"; then
                output="$output ADMIN"
            fi

            # Check for SSH key
            if [ -f "$home/.ssh/authorized_keys" ]; then
                output="$output SSH"
            fi
            echo "$output"
        fi
    done < /etc/passwd
}

services() {
    echo "Non-Default Services"
    service -e > ../util/files/compare_services.txt
    cd ../util || echo "util directory is missing"
    diff --suppress-common-lines files/compare_services.txt info/default_services.txt
    cd ../core || echo "core direcotry is missing"
}

# List zones
interfaces() {
    echo "Network interfaces:"
    ifconfig -l | tr ' ' '\n' | while read iface; do
        echo "$iface"
    done

    IFACE_COUNT=$(ifconfig -l | wc -w)
    echo "Number of network interfaces: $IFACE_COUNT"
}

# List firewall rules
firewall() {
    # Hopefully only lists those not predefined by the system
    if [ -f /cf/conf/config.xml ]; then
        echo "Firewall rules:"
        awk 'BEGIN{RS="<rule>";FS="\n"} NR>1 {
            is_system=0; details=""
            for(i=1;i<=NF;i++) {
                if ($i ~ /<type>system<\/type>/) is_system=1
                if ($i ~ /<description>/) desc=$i
                if ($i ~ /<action>/) act=$i
                if ($i ~ /<interface>/) iface=$i
                if ($i ~ /<source>/) src=$i
                if ($i ~ /<destination>/) dst=$i
            }
            if (!is_system) {
                details=desc " " act " " iface " " src " " dst
                gsub(/<[^>]+>/, "", details)
                print details
            }
        }' /cf/conf/config.xml
    else
        echo "Firewall config not found."
    fi
}

inventory() {
    users
    services
    interfaces
    firewall
}

inventory