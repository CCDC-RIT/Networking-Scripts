#!/bin/sh

UNUSUAL_PROCESSES=$(paste -sd'|' ../util/unusual_processes.txt)

processes() {
    echo "\nSuspicious processes found:"
    ps aux | awk -v names="$UNUSUAL_PROCESSES" '($1 != "root") || ($11 ~ /\/tmp\//) || ($11 ~ names) {print}'
}

# Check users that are currently logged on
terminals() {
    echo "Active terminals:"
    who

    echo "Active user sessions:"
    last | grep still

    echo "Last 5 terminated user sessions:"
    last | grep -v 'still' | head -n 5
}

# Check cron jobs for each user
cron() {
    for user in $(cut -f1 -d: /etc/passwd); do
        crontab -l -u "$user" 2>/dev/null | grep -v '^#' | grep -v '^$' && echo "User: $user"
    done
}

# Check for rootkits
system() {
    dmesg | grep -i taint || echo "No memory taint detected."
}

saute() {
    processes
    terminals
    cron
    system
}

saute