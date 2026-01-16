#!/bin/sh

UNUSUAL_PROCESSES=$(tr '\n' '|' < ../util/info/unusual_processes.txt | sed 's/|$//')
DEFAULT_CRON=$(cat ../util/info/default_cron.txt)
DEFAULT_SERVICES=$(cat ../util/info/default_services.txt)

processes() {
    echo "Suspicious processes found:"
    ps aux | awk -v names="$UNUSUAL_PROCESSES" '($1 != "root") || ($11 ~ /\/tmp\//) || ($11 ~ names) {print}'
    echo ""
}

connections() {
    echo "##### Network connections #####"
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

    echo ""
}

auth_events() {
    echo "--SSH--"
    grep "sshd" /var/log/auth.log 2>/dev/null | tail -20 || echo "No SSH events in auth.log"
    
    echo ""
    echo "--Web GUI--"
    grep -E "(login|authentication)" /var/log/system.log 2>/dev/null | tail -10 || echo "No GUI auth events found"

    echo ""
}

infra() {
    echo "--DHCP--"
    if [ -f "/var/log/dhcpd.log" ]; then
        tail -20 /var/log/dhcpd.log
    fi

    echo ""
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
    echo ""
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
    echo ""
}

# Check for rootkits and evaluate memory / kernel and disk state
system() {
    echo "--Rootkits--"
    dmesg | grep -i taint || echo "No memory taint detected."
    # show a brief top line if available
    if command -v top >/dev/null 2>&1; then
        top -b -n1 2>/dev/null | head -4 | tail -1 || top -d1 | head -4 | tail -1
    fi
    df -h

    #creates a log file that shows all files that differ from release version
    echo ""
    echo "--Updated Files--"
    LOG="/var/log/freebsd-update-ids.log"
    freebsd-update IDS > "$LOG" 2>&1

    #integrity check on root and user filesystems
    echo ""
    echo "--Filesystem integrity check--"
    LOG_FILE="/var/log/integrity_scan.log"
    mtree -e -p / -f /etc/mtree/BSD.root.dist >> "$LOG_FILE" 2>&1
    mtree -e -p /usr -f /etc/mtree/BSD.usr.dist >> "$LOG_FILE" 2>&1
    echo ""
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

    echo ""
    echo "--Suspicious Kernel Modules--"
    default_module_file="/home/admin/Networking-Scripts-main/pfSense/util/info/default_modules.txt"
    suspicious_found=0
    loaded_modules=$(kldstat | awk 'NR>1 {print $5}') 
    for module in $loaded_modules; do
        if ! grep -q "$module" "$default_module_file"; then
            echo "[ALERT] Suspicious module loaded: $module"
            suspicious_found=1
        fi
    done

    if [ "$suspicious_found" -eq 0 ]; then
        echo "No suspicious modules loaded."
    fi
    echo ""
}

file_perms() {
    echo "--SUID/SGID files--"
    find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null | head -n 50 || echo "find unavailable or no results"

    echo ""
    echo "--World-writable files--"
    find / -xdev -type f -perm -002 -ls 2>/dev/null | head -n 50 || echo "find unavailable or no results"
    echo ""
}

packages() {
    echo "--Packages--"
    if command -v pkg >/dev/null 2>&1; then
        echo "Recently installed/removed (dpkg):"
        if [ -f /var/log/dpkg.log ]; then
            tail -n 20 /var/log/dpkg.log
        fi
    fi

    echo ""
}

audit() {
    processes
    connections
    services
    auth_events
    terminals
    infra
    kernel
    file_perms
    system
    cron
    packages
}

audit