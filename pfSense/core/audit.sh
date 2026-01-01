#!/bin/sh

UNUSUAL_PROCESSES=$(paste -sd'|' ../util/info/unusual_processes.txt)
DEFAULT_CRON=$(cat ../util/info/default_cron.txt)
DEFAULT_SERVICES=$(cat ../util/info/default_services.txt)

processes() {
    echo "Suspicious processes found:"
    ps aux | awk -v names="$UNUSUAL_PROCESSES" '($1 != "root") || ($11 ~ /\/tmp\//) || ($11 ~ names) {print}'
}

connections() {
    echo "Network connections:"
    echo "--TCP--"
    netstat -an | grep tcp | grep ESTABLISHED
    echo "--UDP--"
    netstat -an | grep udp
    echo "Listening services:"
    netstat -an | grep LISTEN
}

services() {
    echo "Non-default services found:"
    service -e | while read -r svc; do
        if ! echo "$DEFAULT_SERVICES" | grep -Fxq "$svc"; then
            echo "$svc"
        fi
    done
}

auth_events() {
    echo "Recent authentication events"

    echo "--SSH--"
    grep "sshd" /var/log/auth.log 2>/dev/null | tail -20 || echo "No SSH events in auth.log"
    
    # Web GUI login attempts
    echo "--Web GUI--"
    grep -E "(login|authentication)" /var/log/system.log 2>/dev/null | tail -10 || echo "No GUI auth events found"
}

infra() {
    echo "--DHCP--"
    if [ -f "/var/log/dhcpd.log" ]; then
        tail -20 /var/log/dhcpd.log
    fi

    echo "--DNS--"
    if [ -f "/var/log/resolver.log" ]; then
        echo "Recent DNS resolver events:"
        tail -20 /var/log/resolver.log
    fi

    if [ -f "/cf/conf/config.xml" ]; then
        echo "Config file last edited: "
        ls -la /cf/conf/config.xml
        echo ""
    fi
    
    echo "Recent configuration changes:"
    grep -E "(config|configuration)" /var/log/system.log 2>/dev/null | tail -10 || echo "No configuration change events found"
    echo ""
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
    cut -f1 -d: /etc/passwd | while read -r user; do
        crontab -l -u "$user" 2>/dev/null | grep -v '^#' | grep -v '^$' | while IFS= read -r job; do
            job_clean=$(echo "$job" | xargs)
            if [ -n "$job_clean" ]; then
                if ! echo "$DEFAULT_CRON" | grep -Fxq "$job_clean"; then
                    echo "Non-default cron job for $user: $job_clean"
                fi
            fi
        done
    done
}

# Check for rootkits and evaluate memory / kernel and disk state
system() {
    dmesg | grep -i taint || echo "No memory taint detected."
    # show a brief top line if available
    if command -v top >/dev/null 2>&1; then
        top -b -n1 2>/dev/null | head -4 | tail -1 || top -d1 | head -4 | tail -1
    fi
    df -h
}

kernel() {
    echo "--Kernel checks--"
    if command -v sysctl >/dev/null 2>&1; then
        for k in net.ipv4.ip_forward net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter net.ipv4.tcp_syncookies net.ipv4.conf.all.accept_source_route; do
            printf "%s: " "$k"
            sysctl -n "$k" 2>/dev/null || echo "(not available)"
        done
    else
        echo "sysctl not available"
    fi
}

file_perms() {
    echo "--SUID/SGID files (top results)--"
    find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null | head -n 50 || echo "find unavailable or no results"

    echo "--World-writable files (top results)--"
    find / -xdev -type f -perm -002 -ls 2>/dev/null | head -n 50 || echo "find unavailable or no results"
}

selinux() {
    echo "--SELinux Status--"
    if command -v getenforce >/dev/null 2>&1; then
        echo "SELinux: $(getenforce 2>/dev/null)"
    else
        echo "SELinux (getenforce) not present"
    fi
    if command -v apparmor_status >/dev/null 2>&1; then
        apparmor_status 2>/dev/null || true
    else
        echo "AppArmor not present"
    fi
}

audit() {
    processes
    services
    terminals
    infra
    kernel
    file_perms
    selinux
    system
    cron
}

audit