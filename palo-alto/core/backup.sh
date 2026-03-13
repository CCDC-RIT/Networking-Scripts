#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/common.sh"

list_backups() {
    log "INFO" "Available backup files:"
    echo ""
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo "No backups found in $BACKUP_DIR"
        return 1
    fi
    
    ls -lh "$BACKUP_DIR"/*.xml 2>/dev/null | awk '{print $9, "("$5")"}' | nl || echo "No backups available"
}

create_backup() {
    log "INFO" "Creating configuration backup"
    
    local backup_file="$BACKUP_DIR/pa-config-$(date +%Y%m%d_%H%M%S).xml"
    
    ssh_exec "show running config" > "$backup_file" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log "INFO" "Backup completed: $backup_file"
        echo "$backup_file"
    else
        error_exit "Backup failed"
    fi
}

backup() {
    validate_config
    create_backup
    list_backups

    # ssh_exec "request commit"; log "INFO" "Changes committed"
}

backup
