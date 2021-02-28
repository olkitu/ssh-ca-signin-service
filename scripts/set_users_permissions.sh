#!/bin/bash
set -e

USERNAME=$1

if [ -z "$USERNAME" ]; then
    echo "Username can't be empty"
    exit 1
fi

chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
chmod 0700 /home/$USERNAME/.ssh
chmod 0600 /home/$USERNAME/.ssh/authorized_keys