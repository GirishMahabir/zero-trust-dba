#!/bin/bash

# Script to backup a MySQL/MariaDB database and encrypt the backup with GPG

# Hardcoded variables
BACKUP_DIR="/home/encrypt-backups/"
GPG_RECIPIENT="dba@mdx-org.com"

# Check if a database name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 database_name"
    exit 1
fi

# Create the backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Check if the gpg recipient key is available
gpg --list-keys "${GPG_RECIPIENT}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "GPG recipient key not found: ${GPG_RECIPIENT}"
    exit 2
fi

DATABASE_NAME="$1"

# Filename for the backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DATABASE_NAME}_${TIMESTAMP}.sql.gz.gpg"

echo "Backing up database: ${DATABASE_NAME} with GPG recipient: ${GPG_RECIPIENT}"

# Perform the backup, gzip compress, and encrypt
mysqldump --socket=/opt/bitnami/mariadb/tmp/mysql.sock -u root "${DATABASE_NAME}" | gzip | gpg --encrypt --recipient "${GPG_RECIPIENT}" --output "${BACKUP_FILE}"

# Verify success
if [ $? -eq 0 ]; then
    echo "Backup successful: ${BACKUP_FILE}"
else
    echo "Backup failed"
    exit 2
fi
