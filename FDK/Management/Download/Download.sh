#!/bin/bash
# Powered by QiGao
# Copyright 2025- alkali. All Rights Reserved.
################################################################

DATE="$(date +%F)"
TIME="$(date +%H-%M-%S)"

mkdir -p "$LOGS_DIR/Download/$1/$DATE"
echo "TIME=$(date +%s%N)" > "$LOGS_DIR/Download/Datasets/$1/$DATE/$TIME.log"

log() {
    echo "[ $(date +"%Y-%m-%d %H:%M:%S") ] $1" >> "$LOGS_DIR/Download/Datasets/$1/$DATE/$TIME.log"
}

log
log "################################################################"

mkdir -p "$REPOSITORIES_DIR/Datasets/$1"
log