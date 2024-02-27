CREATE USER 'monitor'@'%' IDENTIFIED BY 'monPass';
GRANT SELECT, PROCESS, REPLICATION CLIENT ON *.* TO 'monitor'@'%';

ALTER USER 'zero-dba'@'%' IDENTIFIED BY 'shie9yaeb2aesie0lahshiriek2Aegie';
GRANT SELECT, INSERT, UPDATE, DELETE ON employees.* TO 'zero-dba'@'%';

GRANT REPLICATION CLIENT ON *.* TO 'zero-dba'@'%'; -- For replication monitoring
GRANT SELECT ON *.* TO 'zero-dba'@'%'; -- For general monitoring and read operations
GRANT SHOW VIEW, SHOW DATABASES ON *.* TO 'zero-dba'@'%'; -- To show views and databases
GRANT PROCESS ON *.* TO 'zero-dba'@'%'; -- To view the processlist
GRANT RELOAD ON *.* TO 'zero-dba'@'%'; -- For performing flush operations and logs management
GRANT SUPER ON *.* TO 'zero-dba'@'%'; -- For a wider range of admin operations like setting global variables

-- If the user needs to manage other users or permissions
GRANT CREATE USER ON *.* TO 'zero-dba'@'%'; -- To create new users
GRANT GRANT OPTION ON *.* TO 'zero-dba'@'%'; -- To grant/revoke privileges to/from other users

-- If the user needs to perform backup operations
GRANT LOCK TABLES, SELECT ON *.* TO 'zero-dba'@'%'; -- Necessary for some backup operations like mysqldump

-- Apply the changes
FLUSH PRIVILEGES;

set storage_engine=InnoDB;