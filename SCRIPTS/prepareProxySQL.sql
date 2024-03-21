UPDATE global_variables SET variable_value='/var/lib/proxysql/queries.log' WHERE variable_name='mysql-eventslog_filename';
UPDATE global_variables SET variable_value='10485760' WHERE variable_name='mysql-eventslog_filesize'; -- 10MB, adjust as needed
UPDATE global_variables SET variable_value='1' WHERE variable_name='mysql-eventslog_default_log'; -- 1=enabled
UPDATE global_variables SET variable_value='2' WHERE variable_name='mysql-eventslog_format'; -- JSON

-- select * from global_variables where variable_name like 'mysql-eventslog%' or variable_name like 'mysql-query_rules%';

-- SSL Configuration (SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-ssl%';)
SET mysql-ssl_p2s_cert="/var/lib/proxysql/certs/client-cert.pem";
SET mysql-ssl_p2s_key="/var/lib/proxysql/certs/client-key.pem";
SET mysql-ssl_p2s_ca="/var/lib/proxysql/certs/ca-cert.pem";

-- Anonymize first_name and last_name
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply)
VALUES (1000, 1, '^SELECT (.*)first_name, (.*)last_name(.*) FROM employees', 'SELECT MD5(CONCAT(emp_no, ''_first'')) AS first_name, MD5(CONCAT(emp_no, ''_last'')) AS last_name \3 FROM employees', 1);

-- -- Anonymize birth_date
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply)
VALUES (1001, 1, '^SELECT (.*)birth_date(.*) FROM employees', 'SELECT DATE_ADD(''1970-01-01'', INTERVAL FLOOR(0 + (RAND() * (365 * 50))) DAY) AS birth_date \2 FROM employees', 1);

-- -- Anonymize hire_date
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply)
VALUES (1002, 1, '^SELECT (.*)hire_date(.*) FROM employees', 'SELECT DATE_ADD(''1985-01-01'', INTERVAL FLOOR(0 + (RAND() * (365 * 35))) DAY) AS hire_date \2 FROM employees', 1);

-- -- Anonymize salary
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, replace_pattern, apply)
VALUES (1003, 1, '^SELECT (.*)salary(.*) FROM salaries', 'SELECT ROUND((RAND() * (150000-30000))+30000) AS salary \2 FROM salaries', 1);

-- Update rule_id for last block all rule.
UPDATE mysql_query_rules SET rule_id=1100 WHERE rule_id=900;

-- SELECT rule_id, active, match_pattern, replace_pattern, apply FROM mysql_query_rules;

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;