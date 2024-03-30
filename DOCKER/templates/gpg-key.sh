#!/bin/usr/env bash
gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: DBA
Name-Comment: Backup Key
Name-Email: dba@mdx-org.com
Expire-Date: 0
Passphrase: secure-passphrase
%no-protection
EOF