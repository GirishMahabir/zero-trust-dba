STOP SLAVE;
CHANGE MASTER TO MASTER_SSL=1, MASTER_SSL_CA='/opt/bitnami/mariadb/conf/transit/ca-cert.pem', MASTER_SSL_CERT='/opt/bitnami/mariadb/conf/transit/client-cert.pem', MASTER_SSL_KEY='/opt/bitnami/mariadb/conf/transit/client-key.pem';
START SLAVE;