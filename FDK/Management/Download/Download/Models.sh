# Powered by QiGao
# Copyright 2025- alkali. All Rights Reserved.
################################################################

DATE="$(date +%F)"
TIME="$(date +%H-%M-%S)"

mkdir -p "$LOGS_DIR/Download/Models/$1/$DATE"
echo "TIME=$(date +%s%N)" > "$LOGS_DIR/Download/Models/$1/$DATE/$TIME.log"

log() {
    echo "[ $(date +"%Y-%m-%d %H:%M:%S") ] $1" >> "$LOGS_DIR/Download/Models/$1/$DATE/$TIME.log"
}

log
log "################################################################"

mkdir -p "$REPOSITORIES_DIR/Models/$1"
log

$HUGGINGFACE_DIR download --token "$HUGGING_FACE_TOKEN" --resume-download "$1" --local-dir "$REPOSITORIES_DIR/Models/$1" 2>&1 | tee -a "$LOGS_DIR/Download/Models/$1/$DATE/$TIME.log"

if [ $? -ne 0 ]; then
    log "捕获到计划外错误"
    exit 1
fi