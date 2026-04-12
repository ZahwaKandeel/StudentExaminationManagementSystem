# Backup & Restore Instructions

## Requirements
- PostgreSQL client tools installed (`pg_dump`, `psql`)
- Access to the `iti_exam` database
- Either a `.pgpass` file configured or `PGPASSWORD` environment variable set

## Setting up passwordless authentication

Create a `.pgpass` file in your home directory so scripts
do not prompt for a password:

```bash
# Format: hostname:port:database:username:password
echo "localhost:5432:iti_exam:postgres:your_password" >> ~/.pgpass
chmod 600 ~/.pgpass
```

## Taking a backup

```bash
# Development backup
bash scripts/backup.sh

# Production backup (label differs in filename)
bash scripts/backup.sh production
```

Backup files are saved to the `backups/` folder with a timestamp:
```
backups/iti_exam_development.sql
```

## Restoring from a backup

```bash
# Step 1: identify the backup file you want to restore
ls -lh backups/

# Step 2: run the restore script
bash scripts/restore.sh backups/iti_exam_development.sql
```

The script will ask you to press ENTER before overwriting.
Type Ctrl+C to cancel.

## Manual backup (without the script)

```bash
pg_dump \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d iti_exam \
  -F p \
  --clean \
  --if-exists \
  --no-owner \
  -f backups/manual_backup.sql
```

## Manual restore (without the script)

```bash
psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d iti_exam \
  -v ON_ERROR_STOP=1 \
  -f backups/manual_backup.sql
```

## Restore to a fresh database (clean machine)

```bash
# Step 1: create the database
psql -U postgres -c "CREATE DATABASE iti_exam ENCODING 'UTF8' TEMPLATE template0;"

# Step 2: restore
psql -U postgres -d iti_exam -f backups/iti_exam_development_20260411_143022.sql
```

## Verify restore worked

```bash
psql -U postgres -d iti_exam -c "
SELECT
    'Departments' AS entity, COUNT(*) AS total FROM department
UNION ALL SELECT 'Tracks',      COUNT(*) FROM track
UNION ALL SELECT 'Courses',     COUNT(*) FROM course
UNION ALL SELECT 'Students',    COUNT(*) FROM student
UNION ALL SELECT 'Questions',   COUNT(*) FROM question
UNION ALL SELECT 'Exams',       COUNT(*) FROM exam;"
```

## Backup log

Every run of `backup.sh` appends a line to `backups/backup_log.txt`:
```
2026-04-11 14:30:22 | SUCCESS | iti_exam_development_20260411_143022.sql | 248K | development
```

## Important notes
- The `backups/` folder is listed in `.gitignore` — backup files are
  never committed to GitHub (they contain real data)
- Always take a backup before running any destructive migration
- Keep at least one backup from each major milestone