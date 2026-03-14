#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

system_info() {
    log "INFO" "Auditing system information"
    echo ""
    echo "=== System Information ==="
    ssh_exec "show system info" || log "ERROR" "Failed to retrieve system info"
    echo ""
}

admin_accounts() {
    log "INFO" "Auditing administrator accounts"
    echo ""
    echo "=== Administrator Accounts ==="
    ssh_exec "show running config mgt-config users" || log "WARN" "Could not retrieve admin accounts"
    echo ""
}

auth() {
    log "INFO" "Auditing authentication settings"
    echo ""
    echo "=== Authentication Configuration ==="
    ssh_exec "show running config deviceconfig setting password-policy" || log "WARN" "Could not retrieve password policy"
    ssh_exec "show running config mgt-config authentication" || log "WARN" "Could not retrieve auth config"
    echo ""
}

interfaces() {
    log "INFO" "Auditing network interfaces"
    echo ""
    echo "=== Network Interfaces ==="
    ssh_exec "show network interface ethernet" || log "WARN" "Could not retrieve interface config"
    echo ""
}

routing() {
    log "INFO" "Auditing routing configuration"
    echo ""
    echo "=== Routing Configuration ==="
    ssh_exec "show running config network virtual-router" || log "WARN" "Could not retrieve routing config"
    echo ""
}

security_rules() {
    log "INFO" "Auditing security rules"
    echo ""
    echo "=== Security Rules ==="
    ssh_exec "show running config security rules" || log "WARN" "Could not retrieve rules"
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
    validate_config
    validate_ssh_key
    check_connectivity || error_exit "Cannot reach firewall"

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

    # ssh_exec "request commit"; log "INFO" "Changes committed"
}

audit
