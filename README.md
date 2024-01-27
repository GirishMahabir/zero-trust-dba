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