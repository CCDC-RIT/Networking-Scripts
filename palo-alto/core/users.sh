#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

admins() {
    log "INFO" "Collecting administrator account information"
    
    # shellcheck disable=SC2155
    local inv_file="$CONFIG_DIR/admin-accounts-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Local Administrator Accounts ==="
        ssh_exec "show running config mgt-config users"
        echo ""
        echo "=== LDAP Configuration ==="
        ssh_exec "show running config mgt-config authentication ldap" || echo "LDAP not configured"
        echo ""
        echo "=== RADIUS Configuration ==="
        ssh_exec "show running config mgt-config authentication radius" || echo "RADIUS not configured"
        echo ""
    } > "$inv_file" 2>&1
}

users() {
    admins
}

users