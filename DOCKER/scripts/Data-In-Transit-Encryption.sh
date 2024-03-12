#!/bin/env bash

MARIADB_CERTS_DIR="/opt/bitnami/mariadb/conf/transit/"

# Create Directory for Certificates
mkdir -p "$MARIADB_CERTS_DIR"

# Create CA Certificate
openssl genrsa -out "$MARIADB_CERTS_DIR/ca-key.pem" 4096
openssl req -new -x509 -nodes -days 365 -key "$MARIADB_CERTS_DIR/ca-key.pem" -out "$MARIADB_CERTS_DIR/ca-cert.pem" -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=middlesex.mu"

# Create Server Certificate
openssl genrsa 4096 > "$MARIADB_CERTS_DIR/server-key.pem"
openssl req -new -key "$MARIADB_CERTS_DIR/server-key.pem" -out "$MARIADB_CERTS_DIR/server-req.pem" -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=MariaDBServer"
# Sign the Server Certificate
openssl x509 -req -in "$MARIADB_CERTS_DIR/server-req.pem" -CA "$MARIADB_CERTS_DIR/ca-cert.pem" -CAkey "$MARIADB_CERTS_DIR/ca-key.pem" -CAcreateserial -out "$MARIADB_CERTS_DIR/server-cert.pem" -days 3650 -sha256


# Create Client Certificate
openssl genrsa 4096 > "$MARIADB_CERTS_DIR/client-key.pem"
openssl req -new -key "$MARIADB_CERTS_DIR/client-key.pem" -out "$MARIADB_CERTS_DIR/client-req.pem" -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=Client One"
# Sign the Client Certificate
openssl x509 -req -in "$MARIADB_CERTS_DIR/client-req.pem" -CA "$MARIADB_CERTS_DIR/ca-cert.pem" -CAkey "$MARIADB_CERTS_DIR/ca-key.pem" -CAcreateserial -out "$MARIADB_CERTS_DIR/client-cert.pem" -days 3650 -sha256

# Verify the Certificates
VERIFY=$(openssl verify -CAfile "$MARIADB_CERTS_DIR/ca-cert.pem" "$MARIADB_CERTS_DIR/server-cert.pem" "$MARIADB_CERTS_DIR/client-cert.pem")
VERIFY_COUNT=$(echo "Verification: $VERIFY" | grep -c OK)

if [ "$VERIFY_COUNT" -eq 2 ]; then
    echo "Certificates Verified"
else
    echo "Certificates Verification Failed"
    exit 1
fi

# Set Certificate Permissions
chown -R mysql:mysql "$MARIADB_CERTS_DIR"
chmod 600 "$MARIADB_CERTS_DIR/ca-key.pem" "$MARIADB_CERTS_DIR/server-key.pem" "$MARIADB_CERTS_DIR/client-key.pem"