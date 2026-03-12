#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/palo-alto.conf"

mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR"

log() {
    local level="$1"
    shift
    local message="$@"
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
    
    local ssh_cmd="ssh"
    [[ -n "$PA_KEY" ]] && ssh_cmd="$ssh_cmd -i $PA_KEY"
    ssh_cmd="$ssh_cmd -p $PA_SSH_PORT -o ConnectTimeout=$SSH_TIMEOUT $PA_USER@$FIREWALL_IP"
    
    eval "$ssh_cmd '$command'"
    return $?
}

ssh_exec_timeout() {
    local timeout="$1"
    local command="$2"
    validate_config
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would execute: $command"
        return 0
    fi
    
    local ssh_cmd="ssh"
    [[ -n "$PA_KEY" ]] && ssh_cmd="$ssh_cmd -i $PA_KEY"
    ssh_cmd="$ssh_cmd -p $PA_SSH_PORT -o ConnectTimeout=$timeout $PA_USER@$FIREWALL_IP"
    
    timeout "$timeout" eval "$ssh_cmd '$command'"
    return $?
}

ssh_op_exec() {
    local command="$1"
    ssh_exec "request system info | get" "$command"
}

backup_config() {
    local backup_file="$BACKUP_DIR/pa-config-$(date +%Y%m%d_%H%M%S).xml"
    
    log "INFO" "Backing up configuration to $backup_file"
    
    ssh_exec 'request system info | get' > "$backup_file" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log "INFO" "Backup completed successfully"
        echo "$backup_file"
        return 0
    else
        error_exit "Failed to backup configuration"
    fi
}

list_backups() {
    log "INFO" "Available backups:"
    ls -lh "$BACKUP_DIR"/*.xml 2>/dev/null | awk '{print $9}' | nl
}

get_config() {
    local section="${1:-}"
    if [[ -z "$section" ]]; then
        ssh_exec "show running config"
    else
        ssh_exec "show running config $section"
    fi
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
