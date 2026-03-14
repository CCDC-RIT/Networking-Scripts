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
show network routing-profile
EOF
    
    echo ""
}

security_rules() {
    echo "=== Security Rules ==="
    ssh "$PA_USER@$FIREWALL_IP" "show running security-policy"
    echo ""
}

security_settings() {
    log "INFO" "Current security settings:"
    ssh_exec "show running config deviceconfig system service" || true
    ssh_exec "show running config deviceconfig setting" || true
}

threat_prevention() {
    log "INFO" "Auditing threat prevention profiles"
    echo ""
    echo "=== Threat Prevention Profiles ==="
    ssh_exec "show running config import security" || log "WARN" "Could not retrieve threat prevention config"
    echo ""
}

nat() {
    log "INFO" "Auditing NAT configuration"
    echo ""
    echo "=== NAT Policies ==="
    ssh_exec "show running config rulebase nat" || log "WARN" "Could not retrieve NAT config"
    echo ""
}

logging() {
    log "INFO" "Auditing logging configuration"
    echo ""
    echo "=== Logging Configuration ==="
    ssh_exec "show running config deviceconfig log-settings" || log "WARN" "Could not retrieve log settings"
    ssh_exec "show running config log-collector" || log "WARN" "Could not retrieve log collector config"
    echo ""
}

dns() {
    log "INFO" "Auditing DNS configuration"
    echo ""
    echo "=== DNS Settings ==="
    ssh_exec "show running config deviceconfig setting dns" || log "WARN" "Could not retrieve DNS config"
    echo ""
}

ha() {
    log "INFO" "Auditing High Availability configuration"
    echo ""
    echo "=== High Availability Status ==="
    ssh_exec "show high-availability status" 2>/dev/null || log "INFO" "High availability not enabled"
    echo ""
}

management_access() {
    log "INFO" "Auditing management interface access"
    echo ""
    echo "=== Management Interface Configuration ==="
    ssh_exec "show running config deviceconfig management http-port" || log "WARN" "Could not retrieve management config"
    ssh_exec "show running config deviceconfig management https-port" || log "WARN" "Could not retrieve HTTPS port"
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
