#!/bin/bash

system_info() {
    echo "=== System Information ==="
    ssh "$PA_USER@$FIREWALL_IP" "show system info"
    echo ""
}

interface_info() {
    echo "=== Ethernet Interfaces ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show network interface ethernet
EOF

    echo ""
    echo "=== Management Interface ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show deviceconfig system
EOF

    echo ""
}

zone_info() {
    echo "=== Security Zones ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show zone
EOF

    echo ""
}

policy_info() {
    echo "=== Security Rules Summary ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show rulebase security rules
EOF

    echo ""
}

routing_info() {
    echo "=== Virtual Routers ==="
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" <<EOF
configure
show network virtual-router
EOF

    echo ""
    echo "=== BGP Configuration ==="
    ssh "$PA_USER@$FIREWALL_IP" "show routing protocol bgp summary"
    echo ""
    echo "=== OSPF Configuration ==="
    ssh "$PA_USER@$FIREWALL_IP" "show routing protocol ospf neighbor"
    echo ""
}

inventory() {
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"

    system_info
    interface_info
    zone_info
    policy_info
    routing_info

    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
}

inventory
