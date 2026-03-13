#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

system_info() {
    log "INFO" "Collecting system information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/system-info-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== System Information ==="
        ssh_exec "show system info"
        echo ""
    } > "$inv_file" 2>&1
}

interface_info() {
    log "INFO" "Collecting interface information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/interfaces-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Ethernet Interfaces ==="
        ssh_exec "show network interface ethernet"
        echo ""
        echo "=== Management Interface ==="
        ssh_exec "show running config deviceconfig management interface-mgmt"
        echo ""
    } > "$inv_file" 2>&1
}

zone_info() {
    log "INFO" "Collecting zone information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/zones-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Security Zones ==="
        ssh_exec "show running config network zone"
        echo ""
    } > "$inv_file" 2>&1
}

policy_info() {
    log "INFO" "Collecting security policy information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/policies-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Security Rules Summary ==="
        ssh_exec "show running config security rules" | head -100
        echo ""
    } > "$inv_file" 2>&1
}

routing_info() {
    log "INFO" "Collecting routing information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/routing-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Virtual Routers ==="
        ssh_exec "show running config network virtual-router"
        echo ""
        echo "=== BGP Configuration ==="
        ssh_exec "show running config network router bgp" || echo "BGP not configured"
        echo ""
        echo "=== OSPF Configuration ==="
        ssh_exec "show running config network router ospf" || echo "OSPF not configured"
        echo ""
    } > "$inv_file" 2>&1
}

inventory() {
    validate_config
    validate_ssh_key
    check_connectivity || error_exit "Cannot reach firewall"

    system_info
    interface_info
    zone_info
    policy_info
    routing_info
}

inventory
