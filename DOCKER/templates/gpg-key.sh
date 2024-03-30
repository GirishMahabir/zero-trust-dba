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

# Export the public key
gpg --export -a dba@mdx-org.com > /root/dba.pub
su root -c "gpg --import /root/dba.pub"

# Ensure all the system users that have a home directory, can use the GPG key.
HOMES=$(ls /home)
for HOME in $HOMES; do
  if [ -d /home/$HOME ]; then
    cp /root/dba.pub /home/$HOME/
    chown $HOME:$HOME /home/$HOME/dba.pub
    su $HOME -c "gpg --import /home/$HOME/dba.pub"
  fi
done

