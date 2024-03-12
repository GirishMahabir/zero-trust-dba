#!/bin/env bash

MARIADB_CONF_DIR="/opt/bitnami/mariadb/conf/encryption"

# Create Directory for Encryption Keys
mkdir -p $MARIADB_CONF_DIR

# Generate Encryption Keys
for i in {1..4}; do
    echo "$i;$(openssl rand -hex 64)" >> "$MARIADB_CONF_DIR/keys"
done

# Generate Random Password and Encrypt the Keys File
openssl rand -hex 64 > "$MARIADB_CONF_DIR/password"
# openssl enc -aes-256-cbc -salt -in "$MARIADB_CONF_DIR/keys" -out "$MARIADB_CONF_DIR/keys.enc" -pass file:"$MARIADB_CONF_DIR/password"
openssl enc -aes-256-cbc -salt -pbkdf2 -in "$MARIADB_CONF_DIR/keys" -out "$MARIADB_CONF_DIR/keys.enc" -pass file:"$MARIADB_CONF_DIR/password"

# Remove the Unencrypted Keys File
rm -f "$MARIADB_CONF_DIR/keys"

# Set Permissions
chown -R mysql:mysql "$MARIADB_CONF_DIR"
chown mysql:root -R "$MARIADB_CONF_DIR"
chmod 500 "$MARIADB_CONF_DIR"

chmod 400 "$MARIADB_CONF_DIR/password" "$MARIADB_CONF_DIR/keys.enc"
