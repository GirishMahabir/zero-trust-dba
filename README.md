# zero-trust-dba
Zero-Trust Database Administration with the aim to protect the administrator as well as the data.

# Manual commands - to be automated
- sudo mkdir -p DATA/mariadb
- sudo chown -R 1001:1001 DATA/mariadb/

# Prepare DB
- git clone https://github.com/datacharmer/test_db.git
- cd test_db
- mysql -u root -p < employees.sql
- mysql -u root -p -t < test_employees_md5.sql

## Prepare Monitor User for ProxySQL
- CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
- GRANT USAGE, REPLICATION SLAVE, REPLICATION CLIENT, SLAVE MONITOR ON *.* TO 'monitor'@'%';

# Access ProxySQL
- `docker compose exec -it proxysql mysql -uadmin -padmin -h127.0.0.1 -P6032 --prompt='Admin> '``

# Sysbench
- sudo zypper refresh
- sudo zypper install -y sysbench


# Audit Log on Every Machine -> Filebeat -> ElasticSearch



# ProxySQL JSON Log
```sql
SET mysql-eventslog_format=2;
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
```


# TODO:
- [x] Finilize Query Rules for annomized data.
- [x] Ensure Logs are being stored in a proper format.
- [x] Ensure Logs are being sent to ElasticSearch and can be viewed in Kibana.
- [ ] Configure Data at Rest Encryption.
- [ ] Configure Data in Transit Encryption.
- [ ] System Admin Sudo (Limits)



# Access
source DOCKER/.env

## ProxySQL Admin
mysql -h127.0.0.1 -P6032 -uradmin -pgo0Daeghai5Xai9te1faenaoPiedohsh --prompt='PSSQL Admin> '

## MySQL Admin
mysql -h127.0.0.1 -P3306 -uroot -p$MARIADB_ROOT_PASSWORD --prompt='MySQL Master> '
mysql -h127.0.0.1 -P3307 -uroot -p$MARIADB_ROOT_PASSWORD --prompt='MySQL Slave> '

## MySQL data_ops User
mysql -h127.0.0.1 -P6033 -udata_ops -paer6eethe7aiShe6uoqu4ieTeef6aig3 --prompt='PSSQL data_ops> '




# Resources
- https://severalnines.com/blog/full-mariadb-encryption-rest-and-transit-maximum-data-protection-part-one/
- https://severalnines.com/blog/full-mariadb-encryption-rest-and-transit-maximum-data-protection-part-two/