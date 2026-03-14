#!/bin/bash

system_info() {
    echo "=== System Information ==="
    ssh "$PA_USER@$FIREWALL_IP" "show system info"
    echo ""
}

admin_accounts() {
    echo "=== Administrator Accounts ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show mgt-config users
EOF
    
    echo ""
}

auth() {
    echo "=== Authentication Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show mgt-config password-complexity
EOF

    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show mgt-config password-profile
EOF
    echo ""
}

interfaces() {
    echo "=== Network Interfaces ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show network interface
EOF

    echo ""
}

routing() {
    echo "=== Routing Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show network virtual-router
EOF
    
    echo ""
}

security_rules() {
    echo "=== Security Rules ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show rulebase security rules
EOF

    echo ""
}

security_settings() {
    echo "=== Security Settings ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig system service
show deviceconfig setting
EOF

    echo ""
}

threat_prevention() {
    echo "=== Threat Prevention Profiles ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show profiles antivirus
show profiles spyware
show profiles vulnerability
EOF

    echo ""
}

nat() {
    echo "=== NAT Policies ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show rulebase nat rules
EOF

    echo ""
}

logging() {
    echo "=== Logging Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig setting logging
show log-settings profiles
EOF

    echo ""
}

dns() {
    echo "=== DNS Settings ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig system dns-setting
EOF

    echo ""
}

ha() {
    echo "=== High Availability Status ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" "show high-availability state"

    echo ""
}

management_access() {
    echo "=== Management Interface Configuration ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig system service
EOF

    echo ""
}

audit() {
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"

    system_info
    admin_accounts
    auth
    interfaces
    routing
    security_rules
    security_settings
    threat_prevention
    nat
    logging
    dns
    ha
    management_access

    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
}

audit
