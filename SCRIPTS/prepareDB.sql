-- Replication User SSL
ALTER USER 'repl_user'@'%' REQUIRE SSL;

-- Monitoring User
-- Monitors the database and replication status.
CREATE USER 'monitor'@'%' IDENTIFIED BY 'monPass' REQUIRE SSL;
GRANT SELECT, PROCESS, REPLICATION CLIENT, SLAVE MONITOR ON *.* TO 'monitor'@'%';

-- Data Operations User
-- Handles CRUD operations on the employees database.
CREATE USER 'data_ops'@'%' IDENTIFIED BY 'aer6eethe7aiShe6uoqu4ieTeef6aig3' REQUIRE SSL;
GRANT SELECT, INSERT, UPDATE, DELETE ON employees.* TO 'data_ops'@'%';

-- Database Monitoring User
-- Responsible for monitoring database performance and replication status.
CREATE USER 'db_monitor'@'%' IDENTIFIED BY 'jae9shequ3Kohsoo5mee5oongii2ique' REQUIRE SSL;
GRANT REPLICATION CLIENT, SHOW VIEW, SHOW DATABASES, PROCESS ON *.* TO 'db_monitor'@'%';

-- Backup OperatorSCRIPTS/prepareDB.sql
-- Performs database backups, requiring read and lock table permissions.
CREATE USER 'backup_operator'@'%' IDENTIFIED BY 'aeng7Ijoj9eeyie8OoThiojeitho8Jie' REQUIRE SSL;
GRANT SELECT, LOCK TABLES ON *.* TO 'backup_operator'@'%';

-- System Administrator
-- Manages high-level administrative tasks and user permissions.
CREATE USER 'sys_admin'@'%' IDENTIFIED BY 'goong1eeQuooW0xeungooPheer9raacu' REQUIRE SSL;
GRANT RELOAD, SUPER, CREATE USER, GRANT OPTION ON *.* TO 'sys_admin'@'%';

-- Apply the changes
FLUSH PRIVILEGES;

set storage_engine=InnoDB;