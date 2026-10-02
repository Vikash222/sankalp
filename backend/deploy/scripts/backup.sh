#!/usr/bin/env bash
# ==============================================================================
# Sankalp API - Automated Daily MySQL & Configuration Backup Script
# ==============================================================================
# Suggested Cron:
# 0 2 * * * /var/www/sankalp/backend/deploy/scripts/backup.sh >> /var/log/sankalp_backup.log 2>&1
# ==============================================================================

set -euo pipefail

BACKUP_DIR="/var/backups/sankalp"
DATE=$(date +"%Y%m%d_%H%M%S")
PROJECT_DIR="/var/www/sankalp/backend"

# Database Configuration (reads directly from .env if available, or defaults)
if [ -f "${PROJECT_DIR}/.env" ]; then
    DB_NAME=$(grep '^DB_DATABASE=' "${PROJECT_DIR}/.env" | cut -d '=' -f2)
    DB_USER=$(grep '^DB_USERNAME=' "${PROJECT_DIR}/.env" | cut -d '=' -f2)
    DB_PASS=$(grep '^DB_PASSWORD=' "${PROJECT_DIR}/.env" | cut -d '=' -f2)
    DB_HOST=$(grep '^DB_HOST=' "${PROJECT_DIR}/.env" | cut -d '=' -f2)
    DB_PORT=$(grep '^DB_PORT=' "${PROJECT_DIR}/.env" | cut -d '=' -f2)
else
    DB_NAME="sankalp_production"
    DB_USER="sankalp_user"
    DB_PASS=""
    DB_HOST="127.0.0.1"
    DB_PORT="3306"
fi

mkdir -p "${BACKUP_DIR}/db"
mkdir -p "${BACKUP_DIR}/config"

DB_BACKUP_FILE="${BACKUP_DIR}/db/sankalp_${DATE}.sql.gz"
CONFIG_BACKUP_FILE="${BACKUP_DIR}/config/env_${DATE}.bak"

echo "[$DATE] Starting database backup for database: ${DB_NAME}..."

# Export database with locks minimized for production
if [ -n "${DB_PASS}" ]; then
    MYSQL_PWD="${DB_PASS}" mysqldump -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" \
        --single-transaction \
        --quick \
        --routines \
        --triggers \
        "${DB_NAME}" | gzip -9 > "${DB_BACKUP_FILE}"
else
    mysqldump -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" \
        --single-transaction \
        --quick \
        --routines \
        --triggers \
        "${DB_NAME}" | gzip -9 > "${DB_BACKUP_FILE}"
fi

# Secure backup permissions
chmod 600 "${DB_BACKUP_FILE}"
echo "[$DATE] Database backup created: ${DB_BACKUP_FILE} ($(du -h "${DB_BACKUP_FILE}" | cut -f1))"

# Backup environment file securely
if [ -f "${PROJECT_DIR}/.env" ]; then
    cp "${PROJECT_DIR}/.env" "${CONFIG_BACKUP_FILE}"
    chmod 600 "${CONFIG_BACKUP_FILE}"
    echo "[$DATE] Environment config backed up to: ${CONFIG_BACKUP_FILE}"
fi

# Retention Policy: Prune backups older than 14 days
echo "[$DATE] Pruning backups older than 14 days..."
find "${BACKUP_DIR}/db" -type f -name "sankalp_*.sql.gz" -mtime +14 -delete
find "${BACKUP_DIR}/config" -type f -name "env_*.bak" -mtime +14 -delete

echo "[$DATE] Backup and retention cycle completed successfully."
