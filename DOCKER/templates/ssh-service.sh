#!/usr/bin/env bash

# Check if ssh process is running
if [ -z "$(ps -ef | grep sshd | grep -v grep)" ]
then
    /usr/sbin/sshd -D &
else
    echo "SSH is running"
fi