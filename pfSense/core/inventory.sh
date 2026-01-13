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
    if [ -f /cf/conf/config.xml ]; then{
        echo "Firewall rules:"
        awk 'BEGIN{RS="<rule>"; FS="\n"} NR>1 {
            descr=type=iface=src=dst=""
            ins=0; ind=0

            for (i=1; i<=NF; i++) {
            line=$i

            # Track when we're inside <source>...</source> and <destination>...</destination>
            if (line ~ /<source>/) { ins=1; continue_line=1 }
            else if (line ~ /<\/source>/) { ins=0; continue_line=1 }
            else if (line ~ /<destination>/) { ind=1; continue_line=1 }
            else if (line ~ /<\/destination>/) { ind=0; continue_line=1 }
            else { continue_line=0 }

            if (continue_line) continue_line=0

            # Top-level fields
            if (line ~ /<descr>/) {
            tmp=line
            gsub(/.*<descr>/,"",tmp); gsub(/<\/descr>.*/,"",tmp)
            descr=tmp
            }
            else if (line ~ /<type>/) {
            tmp=line
            gsub(/.*<type>/,"",tmp); gsub(/<\/type>.*/,"",tmp)
            type=tmp
            }
            else if (line ~ /<interface>/) {
            tmp=line
            gsub(/.*<interface>/,"",tmp); gsub(/<\/interface>.*/,"",tmp)
            iface=tmp
            }

            # Source block (any / network / address)
            else if (ins) {
            if (line ~ /<any\/>/) src="any"
            else if (line ~ /<network>/) {
                tmp=line
                gsub(/.*<network>/,"",tmp); gsub(/<\/network>.*/,"",tmp)
                src=tmp
            }
            else if (line ~ /<address>/) {
                tmp=line
                gsub(/.*<address>/,"",tmp); gsub(/<\/address>.*/,"",tmp)
                src=tmp
            }
            }

            # Destination block (any / network / address)
            else if (ind) {
            if (line ~ /<any\/>/) dst="any"
            else if (line ~ /<network>/) {
                tmp=line
                gsub(/.*<network>/,"",tmp); gsub(/<\/network>.*/,"",tmp)
                dst=tmp
            }
            else if (line ~ /<address>/) {
                tmp=line
                gsub(/.*<address>/,"",tmp); gsub(/<\/address>.*/,"",tmp)
                dst=tmp
            }
            }
        }

        # Skip empty records
        if (iface == "" && descr == "" && type == "" && src == "" && dst == "") next

        if (descr == "") descr="(no descr)"
        if (src == "") src="(unspecified)"
        if (dst == "") dst="(unspecified)"

        printf "%s | %s | %s | %s -> %s\n", iface, type, descr, src, dst
        # awk 'BEGIN{RS="<rule>";FS="\n"} NR>1 {
        #     is_system=0; details=""
        #     for(i=1;i<=NF;i++) {
        #         if ($i ~ /<type>system<\/type>/) is_system=1
        #         if ($i ~ /<descr>/) desc=$i
        #         if ($i ~ /<action>/) act=$i
        #         if ($i ~ /<interface>/) iface=$i
        #         if ($i ~ /<source>/) src=$i
        #         if ($i ~ /<destination>/) dst=$i
        #     }
        #     if (!is_system) {
        #         details=desc " " act " " iface " " src " " dst
        #         gsub(/<[^>]+>/, "", details)
        #         print details
        #     }
        # }' /cf/conf/config.xml
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