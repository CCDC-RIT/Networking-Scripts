#!/bin/bash

ssh_run() {
    ssh -p "$PA_SSH_PORT" \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o StrictHostKeyChecking=no \
    "$PA_USER@$FIREWALL_IP" "$1"
}

connectivity_status() {
    echo ""
    echo "=== WAN Interface Status ==="
    ssh_run "show interface all" || echo "Could not retrieve interface status"
    
    echo ""
    echo "=== BGP Status ==="
    ssh_run "show routing protocol bgp summary" 2>/dev/null || echo "BGP not enabled or not available"
    
    echo ""
    echo "=== Route Count ==="
    ssh_run "show routing route" 2>/dev/null || echo "Routing table not available"
    echo ""
}

ha_status() {
    echo ""
    echo "=== HA Status ==="
    ssh_run "show high-availability state" 2>/dev/null || echo "HA not enabled on this system"
    echo ""
}

threats() {
    echo ""
    echo "=== Recent Threats Blocked ==="
    ssh_run "show log threat direction backward count 20" 2>/dev/null || echo "Could not retrieve threat logs"
    echo ""
}

rule_hits() {
    echo ""
    echo "=== Top Security Rules (by hits) ==="
    ssh_run "show rule-hit-count vsys vsys1 rule-base security rules all" 2>/dev/null || \
    echo "Could not retrieve rule hit counts"
    echo ""
}

health() {
    ssh_run "set cli pager off" || true

    connectivity_status
    ha_status
    threats
    rule_hits

    ssh_run "set cli pager on" || true
}

health
