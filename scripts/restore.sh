#!/bin/bash
# =============================================================
# File    : scripts/restore.sh
# Purpose : Restore the iti_exam database from a backup file
# Usage   : bash scripts/restore.sh backups/iti_exam_development_20260411_143022.sql
# WARNING : This DROPS and recreates all tables in the database
#           All existing data will be lost
# =============================================================

# ---------- configuration ----------
DB_NAME="iti_exam"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
# -----------------------------------

# Check that a backup file was passed as argument 
if [ -z "$1" ]; then
    echo "ERROR: No backup file specified."
    echo "Usage: bash scripts/restore.sh <path_to_backup.sql>"
    exit 1
fi

BACKUP_FILE="$1"

# Check that the file actually exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: File not found: $BACKUP_FILE"
    exit 1
fi

echo "============================================"
echo " ITI Exam DB Restore"
echo " Database  : $DB_NAME"
echo " Host      : $DB_HOST:$DB_PORT"
echo " User      : $DB_USER"
echo " From file : $BACKUP_FILE"
echo " Started   : $(date)"
echo "============================================"
echo ""
echo "WARNING: This will overwrite all data in $DB_NAME"
echo "Press ENTER to continue or Ctrl+C to cancel..."
read

# Run the restore using psql
# The backup file contains DROP + CREATE + INSERT statements
# so psql simply executes them in order
psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "RESTORE SUCCESSFUL"
    echo "Database $DB_NAME restored from $BACKUP_FILE"
    echo "Finished : $(date)"
else
    echo ""
    echo "RESTORE FAILED — check psql error above"
    exit 1
fi