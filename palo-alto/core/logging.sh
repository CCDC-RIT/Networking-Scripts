#!/bin/bash

configure_traffic_logging() {
    echo "=== Configure Traffic Logging ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set log-settings profiles default match-list default send-to-panorama no
EOF

    echo ""
}

configure_threat_logging() {
    echo "=== Configure Threat Logging ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set log-settings profiles default match-list default log-type threat
set log-settings profiles default match-list default send-to-panorama no
EOF

    echo ""
}

configure_system_logging() {
    echo "=== Configure System Logging ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set shared log-settings system match-list default action send-to-panorama no
set shared log-settings config match-list default action send-to-panorama no
EOF

    echo ""
}

configure_log_storage() {
    echo "=== Configure Local Log Storage ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set deviceconfig setting logging max-log-storage 10
EOF

    echo ""
}

show_logging_config() {
    echo "=== Log Settings ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig setting logging
show log-settings profiles
EOF

    echo ""
    echo "=== Log Collectors ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show log-collector-group
EOF

    echo ""
}

view_recent_logs() {
    echo "=== Last 50 System Events ==="
    ssh "$PA_USER@$FIREWALL_IP" "show log system direction backward count 50"
    echo ""
}

view_security_logs() {
    echo "=== Last 50 Security Events ==="
    ssh "$PA_USER@$FIREWALL_IP" "show log threat direction backward count 50"
    echo ""
}

logging() {
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"

    configure_traffic_logging
    configure_threat_logging
    configure_system_logging
    configure_log_storage

    view_recent_logs
    view_security_logs 
    show_logging_config

    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
    # ssh "$PA_USER@$FIREWALL_IP" "request commit"
}

logging
