# MariaDB Data In Transit Encryption

## MariaDB Client-Server Encryption
```bash
mkdir -p /etc/mysql/transit/
cd /etc/mysql/transit/
```
- Create certificate authority (CA) key and certificate:
```bash
openssl genrsa 4096 > ca-key.pem
openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca.pem -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=middlesex.mu"
```

- Create server key and certificate for the server:
```bash
openssl genrsa 4096 > server-key.pem
openssl req -new -key server-key.pem -out server-req.pem -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=MariaDBServer"
```

- Sign the server certificate with the CA key:
```bash
openssl x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 3650 -sha256
```

- Create client key and certificate for the client:
```bash
openssl genrsa 4096 > client-key.pem
openssl req -new -key client-key.pem -out client-req.pem -subj "/C=MU/ST=Black River/L=Flic en Flac/O=CSSE/CN=Client One"
```

```sql
GRANT SELECT ON employees.* TO 'data_ops'@'%' IDENTIFIED BY 'PASSWORD' REQUIRE SSL REQUIRE SUBJECT '/CN=Client One';
```

- Sign the client certificate with the CA key:
```bash
openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 3650 -sha256
```

- Verify the certificates:
```bash
openssl verify -CAfile ca.pem server-cert.pem client-cert.pem
```

### Configuring SSL for MariaDB
- Make sure certificates are available on all servers.
```bash
mkdir -p /etc/mysql/transit/
# COPY FROM MASTER
chown -R mysql:mysql *
chmod 600 client-key.pem server-key.pem ca-key.pem
```

- Adapt MariaDB configuration file:
```
ssl-ca=/etc/mysql/transit/ca.pem
ssl-cert=/etc/mysql/transit/server-cert.pem
ssl-key=/etc/mysql/transit/server-key.pem
```

- Restart MariaDB:
```bash
systemctl restart mariadb
```

## Connecting Via SSL
```bash
mysql -h127.0.0.1 -P3306 -uroot -p$MARIADB_ROOT_PASSWORD --ssl-cert=/etc/mysql/transit/client-cert.pem --ssl-key=/etc/mysql/transit/client-key.pem --ssl-ca=/etc/mysql/transit/ca.pem --prompt='MySQL Master> '
```

## Create a Database user that requires SSL
```sql
CREATE USER 'data_ops'@'%' IDENTIFIED BY 'PASSWORD' REQUIRE SSL REQUIRE SUBJECT '/CN=Client One';
```

# Replication Encryption
- On client nodes:
```ini
[client]
ssl-ca=/etc/mysql/transit/ca.pem
ssl-cert=/etc/mysql/transit/client-cert.pem
ssl-key=/etc/mysql/transit/client-key.pem
```

- Stop the slave:
```sql
STOP SLAVE;
```

- Force the replication user to use SSL:
```sql
ALTER USER 'replication'@'%' REQUIRE SSL;
```

- Test the connection:
```bash
mysql -urpl_user -p -h192.168.0.91 -P 3306 --ssl -e 'status'
```

- Specify the SSL options in the CHANGE MASTER TO statement:
```sql
 CHANGE MASTER TO MASTER_SSL = 1, MASTER_SSL_CA = '/etc/mysql/transit/ca.pem', MASTER_SSL_CERT = '/etc/mysql/transit/client-cert.pem', MASTER_SSL_KEY = '/etc/mysql/transit/client-key.pem';
```

- Start the slave:
```sql
START SLAVE;
SHOW SLAVE STATUS\G
```

- USE TCPDUMP TO VERIFY SSL CONNECTIONS
```bash
tcpdump -i eth0 -s 0 -l -w - 'src port 3306 or dst port 3306' | strings
```