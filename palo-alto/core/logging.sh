#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

configure_traffic_logging() {
    log "INFO" "Configuring traffic logging"
    ssh_exec "set deviceconfig setting log-settings log-traffic yes" || log "WARN" "Traffic logging configuration may exist"
}

configure_threat_logging() {
    log "INFO" "Configuring threat logging"
    
    ssh_exec "set deviceconfig setting log-settings log-threat yes" || log "WARN" "Threat logging configuration may exist"
    ssh_exec "set deviceconfig setting log-settings log-url yes" || log "WARN" "URL logging may already be configured"
    ssh_exec "set deviceconfig setting log-settings log-file yes" || log "WARN" "File logging may already be configured"
}

configure_system_logging() {
    log "INFO" "Configuring system event logging"
    
    ssh_exec "set deviceconfig setting log-settings log-system yes" || log "WARN" "System logging may already be configured"
    ssh_exec "set deviceconfig setting log-settings log-auth yes" || log "WARN" "Authentication logging may already be configured"
}

configure_log_storage() {
    log "INFO" "Configuring local log storage"
    
    ssh_exec "set deviceconfig log-settings disk-quota 10 enable yes" || log "WARN" "Log quota configuration may exist"
}

show_logging_config() {
    log "INFO" "Current logging configuration:"
    echo ""
    echo "=== Log Settings ==="
    ssh_exec "show running config deviceconfig log-settings" || log "WARN" "Could not retrieve log settings"
    echo ""
    echo "=== Log Collectors ==="
    ssh_exec "show running config log-collector" || log "WARN" "No external log collectors configured"
    echo ""
}

view_recent_logs() {
    log "INFO" "Recent system logs:"
    echo ""
    echo "=== Last 50 System Events ==="
    ssh_exec "show log system | tail 50" || log "WARN" "Could not retrieve system logs"
    echo ""
}

view_security_logs() {
    log "INFO" "Recent security logs:"
    echo ""
    echo "=== Last 50 Security Events ==="
    ssh_exec "show log security | tail 50" || log "WARN" "Could not retrieve security logs"
    echo ""
}

logging() {
    validate_config
    validate_ssh_key
    check_connectivity || error_exit "Cannot reach firewall"

    configure_traffic_logging
    configure_threat_logging
    configure_system_logging
    configure_log_storage

    view_recent_logs
    view_security_logs 
    show_logging_config
    
    # ssh_exec "request commit"; log "INFO" "Changes committed"
}

logging
