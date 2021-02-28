#!/bin/bash
set -e

VALIDITY="-5m:+1d"
CA_PATH=/etc/ssh/ssh_ca
TIMESTAMP=`date +%s`

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root (sudo)"
    exit 1
fi

if [ ! -f $CA_PATH ]; then
    echo "CA not found"
    exit 1
fi

USERNAME=$SUDO_USER
if [ -z '$USERNAME' ]; then
    USERNAME=`who am i | awk '(print $1)'`
fi

cat /home/$USERNAME/.ssh/authorized_keys | head -n1 > /home/$USERNAME/.ssh/$USERNAME.pub
SSHKEY=/home/$USERNAME/.ssh/$USERNAME.pub
if [ ! -f $SSHKEY ]; then
    echo "SSHKEY is not set"
    exit 1
fi

PRINCIPALS=`php /usr/local/bin/get_user_principals.php --username=$USERNAME`

# Sign in and write command to comment
COMMENT=`ssh-keygen -s $CA_PATH -I $USERNAME -n $PRINCIPALS -V $VALIDITY -z $TIMESTAMP $SSHKEY 2>&1`

cat /home/$USERNAME/.ssh/$USERNAME-cert.pub
echo "# $COMMENT"