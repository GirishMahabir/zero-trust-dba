UPDATE global_variables SET variable_value='/var/lib/proxysql/queries.log' WHERE variable_name='mysql-eventslog_filename';
UPDATE global_variables SET variable_value='10485760' WHERE variable_name='mysql-eventslog_filesize'; -- 10MB, adjust as needed
UPDATE global_variables SET variable_value='1' WHERE variable_name='mysql-eventslog_default_log'; -- 1=enabled
UPDATE global_variables SET variable_value='2' WHERE variable_name='mysql-eventslog_format'; -- JSON
SET mysql-auditlog_filename="/var/lib/proxysql/proxysql-audit.log";

-- select * from global_variables where variable_name like 'mysql-eventslog%' or variable_name like 'mysql-query_rules%';

-- SSL Configuration Backend (SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-ssl%';)
SET mysql-ssl_p2s_cert="/var/lib/proxysql/certs/client-cert.pem";
SET mysql-ssl_p2s_key="/var/lib/proxysql/certs/client-key.pem";
SET mysql-ssl_p2s_ca="/var/lib/proxysql/certs/ca-cert.pem";

-- SSL Configuration Frontend (SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-ssl%';)
SET mysql-have_ssl=1; -- Certificates will be automatically generated.

-- Create Rules For dba User
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply, error_msg, username) VALUES
(100, 1, '^SHOW MASTER STATUS', 10, 1, NULL, 'dba'),
(101, 1, '^SHOW BINARY LOGS', 10, 1, NULL, 'dba'),
(102, 1, '^SHOW PROCESSLIST', 10, 1, NULL, 'dba'),
(103, 1, '^SHOW FULL PROCESSLIST', 10, 1, NULL, 'dba'),
(104, 1, '^SHOW STATUS', 10, 1, NULL, 'dba'),
(105, 1, '^SHOW VARIABLES', 10, 1, NULL, 'dba'),
(106, 1, '^SHOW TABLE STATUS', 10, 1, NULL, 'dba'),
(107, 1, '^SHOW TABLES', 10, 1, NULL, 'dba'),
(108, 1, '^SHOW CREATE TABLE', 10, 1, NULL, 'dba'),
(109, 1, '^SHOW DATABASES', 10, 1, NULL, 'dba'),
(110, 1, '^SHOW GRANTS', 10, 1, NULL, 'dba'),
(111, 1, '^SHOW PRIVILEGES', 10, 1, NULL, 'dba'),
(112, 1, '^SHOW SLAVE HOSTS', 10, 1, NULL, 'dba'),
(113, 1, '^SHOW SLAVE STATUS', 20, 1, NULL, 'dba'),
(114, 1, '^SHOW RELAYLOG EVENTS', 10, 1, NULL, 'dba'),
(115, 1, '^EXPLAIN', 10, 1, NULL, 'dba'),
(201, 1, '^SHOW RELAYLOG EVENTS', 20, 1, NULL, 'dba'),
(202, 1, '^START SLAVE', 20, 1, NULL, 'dba'),
(203, 1, '^STOP SLAVE', 20, 1, NULL, 'dba'),
(204, 1, '^CHANGE MASTER TO', 20, 1, NULL, 'dba'),
(205, 1, '^RESET SLAVE', 20, 1, NULL, 'dba'),
(206, 1, '^RESET MASTER', 20, 1, NULL, 'dba'),
(207, 1, '^PURGE BINARY LOGS', 20, 1, NULL, 'dba'),
(208, 1, '^RESET QUERY CACHE', 20, 1, NULL, 'dba'),
(209, 1, '^ANALYZE TABLE', 20, 1, NULL, 'dba'),
(210, 1, '^OPTIMIZE TABLE', 20, 1, NULL, 'dba'),
(211, 1, '^SHOW GLOBAL STATUS LIKE', 20, 1, NULL, 'dba'),
(212, 1, '^SHOW GLOBAL VARIABLES LIKE', 20, 1, NULL, 'dba');

-- Anonymize first_name and last_name
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply, username)
VALUES (1000, 1, '^SELECT (.*)first_name, (.*)last_name(.*) FROM employees', 'SELECT FLOOR(RAND() * 1000000) AS first_name, FLOOR(RAND() * 1000000) AS last_name \3 FROM employees', 1, 'data_ops');

-- Anonymize birth_date
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply, username)
VALUES (1001, 1, '^SELECT (.*)birth_date(.*) FROM employees', 'SELECT DATE_ADD(''1970-01-01'', INTERVAL FLOOR(0 + (RAND() * (365 * 50))) DAY) AS birth_date \2 FROM employees', 1, 'data_ops');

-- Anonymize hire_date
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply, username)
VALUES (1002, 1, '^SELECT (.*)hire_date(.*) FROM employees', 'SELECT DATE_ADD(''1985-01-01'', INTERVAL FLOOR(0 + (RAND() * (365 * 35))) DAY) AS hire_date \2 FROM employees', 1, 'data_ops');

-- Anonymize salary
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply, username)
VALUES (1003, 1, '^SELECT (.*)salary(.*) FROM salaries', 'SELECT ROUND((RAND() * (150000-30000))+30000) AS salary \2 FROM salaries', 1, 'data_ops');

-- Block all other queries
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply, error_msg) VALUES
(99999, 1, '.*', 0, 1, 'Access denied');

-- SELECT rule_id, active, match_pattern, replace_pattern, apply FROM mysql_query_rules;

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;