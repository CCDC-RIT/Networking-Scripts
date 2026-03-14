#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../config.conf"

mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR"

log() {
    local level="$1"
    shift
    # shellcheck disable=SC2124
    local message="$@"
    # shellcheck disable=SC2155
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/palo-alto-$(date +%Y-%m-%d).log"
}

error_exit() {
    log "ERROR" "$@"
    exit 1
}

validate_config() {
    if [[ -z "$FIREWALL_IP" ]]; then
        error_exit "FIREWALL_IP not set. Set via environment variable FIREWALL_IP or config file."
    fi
}

ssh_exec() {
    local command="$1"
    validate_config

    local -a ssh_cmd=(
        ssh
        -p "$PA_SSH_PORT"
        -o "ConnectTimeout=$SSH_TIMEOUT"
        -o "StrictHostKeyChecking=no"
        -o "ServerAliveInterval=15"
        -o "ServerAliveCountMax=2"
        "$PA_USER@$FIREWALL_IP"
        "$command"
    )
    [[ -n "$PA_KEY" ]] && ssh_cmd=(ssh -i "$PA_KEY" "${ssh_cmd[@]:1}")

    if command -v timeout >/dev/null 2>&1; then
        timeout "$SSH_TIMEOUT" "${ssh_cmd[@]}"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$SSH_TIMEOUT" "${ssh_cmd[@]}"
    else
        ssh "${ssh_cmd[@]:1}"
    fi
    return $?
}

ssh_exec_timeout() {
    local timeout="$1"
    local command="$2"
    validate_config

    local -a ssh_cmd=(
        ssh
        -p "$PA_SSH_PORT"
        -o "ConnectTimeout=$timeout"
        -o "StrictHostKeyChecking=no"
        -o "ServerAliveInterval=15"
        -o "ServerAliveCountMax=2"
        "$PA_USER@$FIREWALL_IP"
        "$command"
    )
    [[ -n "$PA_KEY" ]] && ssh_cmd=(ssh -i "$PA_KEY" "${ssh_cmd[@]:1}")

    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout" "${ssh_cmd[@]}"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$timeout" "${ssh_cmd[@]}"
    else
        ssh "${ssh_cmd[@]:1}"
    fi
    return $?
}

ssh_op_exec() {
    local command="$1"
    ssh_exec "request system info | get" "$command"
}

check_connectivity() {
    log "INFO" "Checking connectivity to $FIREWALL_IP:$PA_SSH_PORT"
    
    if timeout "$SSH_TIMEOUT" ssh -p "$PA_SSH_PORT" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$PA_USER@$FIREWALL_IP" "exit" 2>/dev/null; then
        log "INFO" "Connection successful"
        return 0
    else
        log "ERROR" "Failed to connect to firewall"
        return 1
    fi
}

validate_ssh_key() {
    if [[ -n "$PA_KEY" ]] && [[ ! -f "$PA_KEY" ]]; then
        error_exit "SSH key file not found: $PA_KEY"
    fi
}
