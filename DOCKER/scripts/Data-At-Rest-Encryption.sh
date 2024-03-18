#!/bin/env bash

MARIADB_CONF_DIR="/opt/bitnami/mariadb/conf/encryption"

# Create Directory for Encryption Keys
mkdir -p $MARIADB_CONF_DIR

# Generate Encryption Keys
for i in {1..4}; do
    echo "$i;$(openssl rand -hex 32)" >> "$MARIADB_CONF_DIR/keys"
done

# Generate Random Password and Encrypt the Keys File
openssl rand -hex 128 > "$MARIADB_CONF_DIR/password"
# openssl enc -aes-256-cbc -salt -in "$MARIADB_CONF_DIR/keys" -out "$MARIADB_CONF_DIR/keys.enc" -pass file:"$MARIADB_CONF_DIR/password"
# openssl enc -aes-256-cbc -salt -pbkdf2 -in "$MARIADB_CONF_DIR/keys" -out "$MARIADB_CONF_DIR/keys.enc" -pass file:"$MARIADB_CONF_DIR/password"
openssl enc -aes-256-cbc -md sha1 -in "$MARIADB_CONF_DIR/keys" -out "$MARIADB_CONF_DIR/keys.enc" -pass file:"$MARIADB_CONF_DIR/password" 

# Remove the Unencrypted Keys File
rm -f "$MARIADB_CONF_DIR/keys"

# Get ID of the mysql user
MYSQL_USER_ID=$(id -u mysql)

# Set Permissions
chown -R "$MYSQL_USER_ID":"$MYSQL_USER_ID" "$MARIADB_CONF_DIR"

# Set Permissions (Docker/Container Specific Issue May Arise -> Make sure the user is created before setting permissions).
chmod 600 "$MARIADB_CONF_DIR/password" "$MARIADB_CONF_DIR/keys.enc"
