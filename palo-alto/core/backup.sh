#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../config.conf"

mkdir -p "$BACKUP_DIR"

create_backup() {
    echo "Creating configuration backup..."
    
    # shellcheck disable=SC2155
    local backup_file="$BACKUP_DIR/pa-config-$(date +%Y%m%d_%H%M%S).xml"
    
    ssh -p "$PA_SSH_PORT" \
        -o "ConnectTimeout=$SSH_TIMEOUT" \
        -o StrictHostKeyChecking=no \
        "$PA_USER@$FIREWALL_IP" <<EOF > "$backup_file"
configure
show
EOF
    
    if [[ $? -eq 0 ]]; then
        echo "Backup completed!"
    else
        echo "ERROR: Backup failed"
    fi

    echo ""
}

backup() {
    echo "Turning pager off, need manual escape"
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager off"
    create_backup
    echo "Turning pager on, need manual escape"
    ssh "$PA_USER@$FIREWALL_IP" "set cli pager on"
}

backup
