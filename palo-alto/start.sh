#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

start() {
    "$SCRIPT_DIR/core/backup.sh"
    "$SCRIPT_DIR/core/audit.sh"
    "$SCRIPT_DIR/core/logging.sh"
    "$SCRIPT_DIR/core/secure.sh"
}

start