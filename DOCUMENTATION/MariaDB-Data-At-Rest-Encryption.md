# MariaDB Encryption (Data at Rest)
- By default, MariaDB stores data in plain text format. This means that anyone with access to the database files has access to the data.

- Proof of concept: 
  - Create a table with some data
  - Shutdown the database
  - Open the table file with a text editor
  - You can see the data in plain text

```bash
cd /var/lib/mysql # or find find / -name *.ibd 2>/dev/null
ls -l # list the files

systemctl stop mariadb # stop the database

# Open the file:
strings db_name/table_name.ibd
```

- To protect the data, MariaDB provides encryption for data at rest. This means that the data is encrypted when it is written to disk and decrypted when it is read from disk.

- Generate Keys
```bash
mkdir -p /etc/mysql/encryption
cd /etc/mysql/encryption 

echo "1;"$(openssl rand -hex 64) > keys
echo "2;"$(openssl rand -hex 64) >> keys
echo "3;"$(openssl rand -hex 64) >> keys
echo "4;"$(openssl rand -hex 64) >> keys
```

- Encrypt the keys file with a long random password, and store the password in a file:
```bash
openssl rand -hex 128 > password_file
openssl enc -aes-256-cbc -salt -in keys -out keys.enc -pass file:password_file
```
- Adapt MariaDB configuration file (/etc/mysql/mariadb.conf.d/encryption.cnf):
```bash
[mariadb]
## File Key Management
plugin_load_add = file_key_management
file_key_management_filename = /etc/mysql/encryption/keys.enc
file_key_management_filekey = FILE:/etc/mysql/encryption/password_file
file_key_management_encryption_algorithm = aes_cbc

## InnoDB/XtraDB Encryption Setup
innodb_default_encryption_key_id = 1
innodb_encrypt_tables = ON
innodb_encrypt_log = ON
innodb_encryption_threads = 4

## Aria Encryption Setup
aria_encrypt_tables = ON

## Temp & Log Encryption
encrypt-tmp-disk-tables = 1
encrypt-tmp-files = 1
encrypt_binlog = ON
```

- Change ownership of the keys file to the user that runs the MariaDB server:
```bash
cd /etc/mysql/
chown mysql:root -R ./encryption
chmod 500./encryption

cd ./encryption
chmod 400 keys.enc password_file
chmod 644 /etc/mysql/mariadb.conf.d/encryption.cnf
```

# Usage
- Create a new table and insert some data:
```sql
use db_name;
alter table lorem ENCRYPTED=Yes
```

- Verify that the data is encrypted:
```bash
cd /var/lib/mysql
strings db_name/lorem.ibd | head -n 20
```

- While creating a new table, you can specify the encryption option:
```sql
CREATE TABLE ipsum (
UserId INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
FirstName VARCHAR(30) NOT NULL,
LastName VARCHAR(30) NOT NULL
) ENGINE=InnoDB ENCRYPTED=YES;
```

- Enforce encryption for all new tables (encryption.cnf):
```bash
innodb-encrypt-tables=FORCE
```