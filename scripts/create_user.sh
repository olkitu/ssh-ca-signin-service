#!/bin/bash
set -e

USERNAME=$1

if [ -z "$USERNAME" ]; then
    echo "Username can't be empty"
    exit 1
fi

adduser $USERNAME -D
passwd -d $USERNAME
mkdir -p /home/$USERNAME/.ssh