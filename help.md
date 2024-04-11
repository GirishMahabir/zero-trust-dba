# zero-trust-dba
Zero-Trust Database Administration with the aim to protect the administrator as well as the data.

# Sysbench
- sudo zypper refresh
- sudo zypper install -y sysbench


# ProxySQL JSON Log
```sql
SET mysql-eventslog_format=2;
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
```
# Access
source DOCKER/.env
## ProxySQL Admin
mysql -h127.0.0.1 -P6032 -uradmin -pgo0Daeghai5Xai9te1faenaoPiedohsh --prompt='PSSQL Admin> '

## MySQL Admin
mysql -h127.0.0.1 -P3306 -uroot -p$MARIADB_ROOT_PASSWORD --prompt='MySQL Master> '
mysql -h127.0.0.1 -P3307 -uroot -p$MARIADB_ROOT_PASSWORD --prompt='MySQL Slave> '

## PSSQL User
mysql -h127.0.0.1 -P6033 -udata_ops -paer6eethe7aiShe6uoqu4ieTeef6aig3 --prompt='PSSQL data_ops> '

## DBA User
mysql -h127.0.0.1 -P6033 -udba -pgoong1eeQuooW0xeungooPheer9raacu

# Backup Database
mysqldump -h127.0.0.1 -P3306 -udata_ops -paer6eethe7aiShe6uoqu4ieTeef6aig3 employees > employees.sql
mysqldump -h127.0.0.1 -P6033 -ubackup_operator -paeng7Ijoj9eeyie8OoThiojeitho8Jie employees > employees.sql
mysqldump -h127.0.0.1 -P6033 -udba -pgoong1eeQuooW0xeungooPheer9raacu employees > employees.sql

## Success:
- Simulate SSH Connection: `docker exec -udba -it zero-trust-dba-project-mariadb-slave-1 bash`
- Launch Script to backup: `sudo /opt/utils/backup-db.sh employees`


# Resources
- https://severalnines.com/blog/full-mariadb-encryption-rest-and-transit-maximum-data-protection-part-one/
- https://severalnines.com/blog/full-mariadb-encryption-rest-and-transit-maximum-data-protection-part-two/


Dependency
- mariadb-client
- binutils (in container mariadb - strings command)
