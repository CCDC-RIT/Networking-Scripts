#!/bin/bash

admins() {
    echo "=== Local Administrator Accounts ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show mgt-config users
EOF
}

ldap() {
    echo ""
    echo "=== LDAP Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show mgt-config authentication-profile
EOF
}

radius() {
    echo ""
    echo "=== RADIUS Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show shared server-profile radius
EOF

    echo ""
}

users() {
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"

    admins
    ldap
    radius

    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
    # ssh "$PA_USER@$FIREWALL_IP" "request commit"
}

users