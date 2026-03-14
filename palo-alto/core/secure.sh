#!/bin/bash

disable_services() {
    echo "=== Disable Insecure Services ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set deviceconfig system service disable-http yes
set deviceconfig system service disable-telnet yes
EOF

    echo ""
}

password_policy() {
    echo "=== Password Policy ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set mgt-config password-complexity enabled yes
set mgt-config password-complexity minimum-length 12
set mgt-config password-complexity password-history-count 5
set mgt-config password-complexity password-change-period 90
EOF

    echo ""
}

configure_session_timeout() {
    echo "=== Session Timeout ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set deviceconfig setting management idle-timeout 15
EOF

    echo ""
}

https() {
    echo "=== HTTPS Management Only ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set deviceconfig system service disable-http yes
EOF

    echo ""
}

enable_threat_prevention() {
    echo "=== Threat Prevention Profiles ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set profiles antivirus default
set profiles spyware default
set profiles vulnerability default
EOF

    echo ""
}

configure_tls() {
    echo "=== TLS Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set deviceconfig system ssl-tls-service-profile Default
EOF

    echo ""
}

configure_audit_logging() {
    echo "=== Audit Logging ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
set shared log-settings config match-list default action send-to-panorama no
EOF

    echo ""
}

secure() {
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"

    disable_services
    password_policy
    configure_session_timeout
    https
    enable_threat_prevention
    configure_tls
    configure_audit_logging 

    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
    # ssh "$PA_USER@$FIREWALL_IP" "request commit"
}

secure
