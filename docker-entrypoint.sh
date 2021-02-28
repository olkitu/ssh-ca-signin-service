#!/bin/bash
set -e

ENV_VARIABLES=$(awk 'BEGIN{for(v in ENVIRON) print "$"v}')

# Write environment variables to file
for FILE in /usr/local/bin/config.php
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

for FILE in /usr/local/bin/sign-ssh-user-cert.sh
do
    envsubst "$ENV_VARIABLES" <$FILE | sponge $FILE
done

# Generate Server Host Keys
ssh-keygen -A

# Copy from secrets the SSH CA Private Key for Sign certificates or create new keypair
if [ -s /run/secrets/$SSH_CA_SECRET ]; then
    echo "Load private key from /run/secrets/$SSH_CA_SECRET"
    cat /run/secrets/$SSH_CA_SECRET > /etc/ssh/ssh_ca
else
    echo "Generating new SSH CA keypair to /etc/ssh/ssh_ca"
    ssh-keygen -q -t rsa -f /etc/ssh/ssh_ca -N '' <<< ""$'\n'"y" 2>&1 >/dev/null
fi
chmod 600 /etc/ssh/ssh_ca

# Get Public key from Private
ssh-keygen -y -f /etc/ssh/ssh_ca > /etc/ssh/ssh_ca.pub

# Sign Host Keys with SSH CA
ssh-keygen -s /etc/ssh/ssh_ca -I $SSH_CA_HOSTNAME -V -5m:+365d -h /etc/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_dsa_key.pub

# Read all public keys from DB
bash /usr/local/bin/wait-for-it.sh $MYSQL_SERVER:$MYSQL_PORT -t 300 -- php /usr/local/bin/write_users_pubkeys.php

# Start server in daemon mode
/usr/sbin/sshd -D -e