#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

disable_services() {
    log "INFO" "Disabling XML API"
    ssh_exec "set deviceconfig system service disable-http-server yes" || log "WARN" "HTTP server already disabled"
    
    log "INFO" "Disabling telnet"
    ssh_exec "set deviceconfig system service disable-telnet yes" || log "WARN" "Telnet already disabled"
}

password_policy() {
    log "INFO" "Setting strong password policy"
    ssh_exec "set deviceconfig setting password-policy enabled yes"
    ssh_exec "set deviceconfig setting password-policy minimum-length 12"
    ssh_exec "set deviceconfig setting password-policy password-history-count 5"
    ssh_exec "set deviceconfig setting password-policy password-expiration 90"
}

configure_session_timeout() {
    log "INFO" "Configuring session timeouts"
    
    ssh_exec "set deviceconfig setting session timeout 15" || log "WARN" "Session timeout already set"
    ssh_exec "set deviceconfig setting default-session-timeout 15" || log "WARN" "Default session timeout already set"
}

https() {
    log "INFO" "Disabling HTTP management"
    ssh_exec "set deviceconfig system service disable-http yes" || log "WARN" "HTTP already disabled"
}

enable_threat_prevention() {
    log "INFO" "Enabling antivirus"
    ssh_exec "set import security profile virus default update-schedule-offset 0" || log "WARN" "Antivirus configuration exists"
    
    log "INFO" "Enabling anti-spyware"
    ssh_exec "set import security profile spyware default update-schedule-offset 0" || log "WARN" "Anti-spyware configuration exists"
    
    log "INFO" "Enabling malware analysis"
    ssh_exec "set threat-prevention malware-analysis enabled yes" || log "WARN" "Malware analysis already enabled"
}

configure_tls() {
    log "INFO" "Setting minimum TLS version to 1.2"
    ssh_exec "set deviceconfig system service ssl-protocol-version tlsv1_2" || log "WARN" "SSL/TLS already configured"
}

configure_audit_logging() {
    ssh_exec "set deviceconfig system auditlog enable yes" || log "WARN" "Audit logging configuration exists"
    log "INFO" "Audit logging enabled for administrative actions"
}

secure() {
    validate_config
    validate_ssh_key
    check_connectivity || error_exit "Cannot reach firewall"

    disable_services
    password_policy
    configure_session_timeout
    https
    enable_threat_prevention
    configure_tls
    configure_audit_logging 

    # ssh_exec "request commit"; log "INFO" "Changes committed"
}

secure
