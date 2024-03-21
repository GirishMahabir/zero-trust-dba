#!/usr/bin/env bash

source DOCKER/.env

# Prepare Replication.
mysql -u root -p$MARIADB_ROOT_PASSWORD -h127.0.0.1 -P3307 < SCRIPTS/prepareReplication.sql

# Git clone employee db in DATA Dir
if [ -d "DATA/EmployeesSampleDB" ]
then
  echo "Directory DATA/EmployeesSampleDB exists."
else
    echo "Directory DATA/EmployeesSampleDB does not exist."
    mkdir -p DATA/EmployeesSampleDB/ 
    git clone https://github.com/datacharmer/test_db.git DATA/EmployeesSampleDB/
fi

# # Prepare DB.
mysql -u root -p$MARIADB_ROOT_PASSWORD -h127.0.0.1 -P3306 < SCRIPTS/prepareDB.sql
cd DATA/EmployeesSampleDB/
mysql -u root -p$MARIADB_ROOT_PASSWORD -h127.0.0.1 -P3306 < employees.sql
cd ../../

# Copy MariaDB Client Certificates to ProxySQL Container
sudo mkdir -p DATA/proxysql-data/certs
cd DOCKER/
MARIADB_CERTS_DIR="/opt/bitnami/mariadb/conf/transit/"
sudo docker compose cp mariadb-master:$MARIADB_CERTS_DIR/ca-cert.pem ../DATA/proxysql-data/certs/ca-cert.pem
sudo docker compose cp mariadb-master:$MARIADB_CERTS_DIR/client-cert.pem ../DATA/proxysql-data/certs/client-cert.pem
sudo docker compose cp mariadb-master:$MARIADB_CERTS_DIR/client-key.pem ../DATA/proxysql-data/certs/client-key.pem
cd ../

# Prepare ProxySQL.
docker exec --env-file DOCKER/.env zero-trust-dba-project-proxysql-1  /bin/bash -c 'mysql -u admin -p$ProxySQL_ADMIN_PASSWORD -h 127.0.0.1 -P6032 </tmp/prepareProxySQL.sql'

# Re-Load ProxySQL.
docker exec --env-file DOCKER/.env zero-trust-dba-project-proxysql-1  /bin/bash -c 'mysql -u admin -p$ProxySQL_ADMIN_PASSWORD -h127.0.0.1 -P6032 -e "LOAD MYSQL SERVERS TO RUNTIME; LOAD MYSQL USERS TO RUNTIME; LOAD MYSQL QUERY RULES TO RUNTIME; LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL VARIABLES TO DISK;"'

# Load Template on Elasticsearch
curl -ksu elastic:$ELASTIC_PASSWORD -X PUT "https://localhost:9200/_index_template/proxysql-logs" -H 'Content-Type: application/json' -d @CONF/proxysql-log-template.json

# Exit Message
echo ""
echo "MariaDB, ProxySQL and Elasticsearch are ready for use."
echo ""
