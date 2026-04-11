#!/bin/bash
# =============================================================
# File    : scripts/backup.sh
# Purpose : Create a full backup of the iti_exam database
# Usage   : bash scripts/backup.sh
#           bash scripts/backup.sh production
# =============================================================

# ---------- configuration ---------- 
DB_NAME="iti_exam"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ENVIRONMENT=${1:-"development"}   
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${ENVIRONMENT}_${TIMESTAMP}.sql"
LOG_FILE="${BACKUP_DIR}/backup_log.txt"
# -----------------------------------


mkdir -p "$BACKUP_DIR"

echo "============================================"
echo " ITI Exam DB Backup"
echo " Database  : $DB_NAME"
echo " Host      : $DB_HOST:$DB_PORT"
echo " User      : $DB_USER"
echo " Output    : $BACKUP_FILE"
echo " Started   : $(date)"
echo "============================================"

# Run pg_dump
# Flags explained:
#   -h  host
#   -p  port
#   -U  username
#   -d  database name
#   -F p  plain SQL format (human readable, easy to inspect and restore)
#   --no-password  rely on .pgpass file or PGPASSWORD env variable
#   -v  verbose output so you can see progress
#   --clean  include DROP statements before CREATE (safer restore)
#   --if-exists  add IF EXISTS to DROP statements (prevents errors on fresh DB)
#   --no-owner  skip ownership commands (portable across different machines)

pg_dump \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -F p \
    --no-password \
    --clean \
    --if-exists \
    --no-owner \
    -v \
    -f "$BACKUP_FILE"


if [ $? -eq 0 ]; then
    
    FILE_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)

    echo ""
    echo "BACKUP SUCCESSFUL"
    echo "File     : $BACKUP_FILE"
    echo "Size     : $FILE_SIZE"
    echo "Finished : $(date)"

    
    echo "$(date) | SUCCESS | $BACKUP_FILE | $FILE_SIZE | $ENVIRONMENT" \
        >> "$LOG_FILE"
else
    echo ""
    echo "BACKUP FAILED — check pg_dump error above"

    
    echo "$(date) | FAILED  | $BACKUP_FILE | — | $ENVIRONMENT" \
        >> "$LOG_FILE"

    exit 1
fi