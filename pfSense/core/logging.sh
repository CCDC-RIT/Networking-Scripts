#!/bin/sh

newsyslog() {
    echo "--Sysctl--"
    sysctl kern.logsigexit=1
    sysctl kern.log_console_output=1
    sysctl kern.lognosys=0
    
    # Configure newsyslog for better log rotation
    cat >> /etc/newsyslog.conf.d/system.log << 'NEWSYSLOG'
/var/log/system.log    644  10   2048  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/dhcpd.log << 'NEWSYSLOG'
/var/log/dhcpd.log     644  10   1024  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/filter.log << 'NEWSYSLOG'
/var/log/filter.log    644  10   2048  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/vpn.log << 'NEWSYSLOG'
/var/log/vpn.log       644  10   1024  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/ppp.log << 'NEWSYSLOG'
/var/log/ppp.log       644  10   512   *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/relayd.log << 'NEWSYSLOG'
/var/log/relayd.log    644  10   512   *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/openvpn.log << 'NEWSYSLOG'
/var/log/openvpn.log   644  10   1024  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    cat >> /etc/newsyslog.conf.d/portalauth.log << 'NEWSYSLOG'
/var/log/portalauth.log 644  10   1024  *     Z    /var/run/syslog.pid  30
NEWSYSLOG

    echo ""
}

# Configure syslog-ng for advanced logging (if available)
syslog_ng() {
    if command -v syslog-ng >/dev/null 2>&1; then
        echo "Configuring syslog-ng for enhanced logging..."
        
        cat > /usr/local/etc/syslog-ng.conf << 'SYSLOGNG'
# Enhanced pfSense syslog-ng configuration
@version: 3.35

options {
    chain_hostnames(no);
    create_dirs(yes);
    keep_hostname(yes);
    log_fifo_size(2048);
    log_msg_size(65536);
    use_dns(no);
    use_fqdn(no);
    stats_freq(43200);
    mark_freq(3600);
};

# Sources
source s_internal {
    internal();
};

source s_network {
    udp(port(514));
    tcp(port(514));
};

source s_kernel {
    file("/dev/klog");
};

source s_local {
    unix-dgram("/var/run/logpriv");
    unix-dgram("/var/run/log");
};

# Destinations
destination d_system { file("/var/log/system.log"); };
destination d_auth { file("/var/log/auth.log"); };
destination d_mail { file("/var/log/mail.log"); };
destination d_daemon { file("/var/log/daemon.log"); };
destination d_kernel { file("/var/log/kernel.log"); };
destination d_user { file("/var/log/user.log"); };
destination d_firewall { file("/var/log/filter.log"); };
destination d_dhcp { file("/var/log/dhcpd.log"); };
destination d_vpn { file("/var/log/vpn.log"); };

# Log everything to catch any missed events
destination d_all { file("/var/log/all.log"); };

# Filters
filter f_auth { facility(auth) or facility(authpriv); };
filter f_mail { facility(mail); };
filter f_daemon { facility(daemon); };
filter f_kernel { facility(kern); };
filter f_user { facility(user); };
filter f_firewall { program("filterlog"); };
filter f_dhcp { program("dhcpd"); };
filter f_vpn { program("openvpn") or program("charon") or program("racoon"); };

# Log statements
log { source(s_local); source(s_internal); source(s_kernel); source(s_network); destination(d_all); };
log { source(s_local); source(s_internal); source(s_network); filter(f_auth); destination(d_auth); };
log { source(s_local); source(s_internal); source(s_network); filter(f_mail); destination(d_mail); };
log { source(s_local); source(s_internal); source(s_network); filter(f_daemon); destination(d_daemon); };
log { source(s_local); source(s_kernel); filter(f_kernel); destination(d_kernel); };
log { source(s_local); source(s_internal); source(s_network); filter(f_user); destination(d_user); };
log { source(s_local); source(s_internal); source(s_network); filter(f_firewall); destination(d_firewall); };
log { source(s_local); source(s_internal); source(s_network); filter(f_dhcp); destination(d_dhcp); };
log { source(s_local); source(s_internal); source(s_network); filter(f_vpn); destination(d_vpn); };
SYSLOGNG
    else
        echo "syslog-ng not available, using standard syslog."
    fi
}

# Restart syslog services
restart_syslog() {
    echo "Restarting syslog services..."
    /etc/rc.d/syslogd restart
    
    # If syslog-ng is configured, restart it too
    if command -v syslog-ng >/dev/null 2>&1; then
        /usr/local/etc/rc.d/syslog-ng restart
    fi
    
    echo "Syslog services restarted."
}

# Main execution function
logging() {
    newsyslog
    syslog_ng
    restart_syslog
}

logging