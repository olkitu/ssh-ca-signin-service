# SSH-CA Signin Service

SSH CA help you to manage SSH public keys in central database without copying all keys to every servers `authorized_keys` file. With principals you can allow access only certain servers. Also with SSH CA you can verify you access to correct server without seeing warning on first connection.

Requirements:

* Docker
* MySQL/MariaDB

## Generate SSH CA private and public keys

Generate SSH CA private and public keys. Don't set passwords.

```shell
ssh-keygen -f ssh-ca
```
## Deploy

### Deploy with docker-compose

This is for development and testing use. Use Swarm on production.

```shell
git clone git@github.com:olkitu/ssh-ca-signin-service.git
cd ssh-ca-signin-service
docker-compose build
docker-compose up -d
```

### Deploy to Swarm

Create Secrets

```shell
cat ssh-ca | docker secret create ssh_ca_private -
```

Deploy stack to Swarm with `docker stack deploy -c docker-compose.yml` command.

```yaml
version: "3.8"
services:
  ssh-ca-sign-service:
    image: olkitu/ssh-ca-signin-service
    ports:
    - 22:22
    environment:
      SSHCA_PUBLIC_KEY: <ssh-ca-public-key>
      SSH_CA_HOSTNAME: sshca.example.org
      MYSQL_SERVER: mariadb
      MYSQL_PORT: 3306
      MYSQL_DATABASE: sshca
      MYSQL_USER: sshca
      MYSQL_PASSWORD: changeme
      USERCERT_VALIDITY: -5m:+1d
      SSH_CA_SECRET: ssh_ca_private
    secrets:
    - ssh_ca_private

secrets:
  ssh_ca_private:
    external: true
```

## Add users to database

Import database [schema](https://github.com/olkitu/ssh-ca-signin-service/blob/master/sql/00-schema.sql) to MySQL/MariaDB. 

Add principals

```sql
INSERT INTO principals (name) VALUES ('admin')
```

Add user to database with SSH public key and principal ID.

```sql
INSERT INTO clients (username, pubkey,principals) VALUES ('username','ssh-rsa ...','1');
```

## Configure Servers use SSH CA

Now configure your end server trust SSH CA public key

Write SSH CA public key to every servers `/etc/ssh/ca.pub` file.

```shell
echo "ssh-rsa ..." > /etc/ssh/ca.pub
```

Configure SSH service `/etc/ssh/sshd_config`

```ssh-config
AuthorizedPrincipalsFile /etc/ssh/authorized_principals/root
TrustedUserCAKeys /etc/ssh/ca.pub
```

Add allowed pricincipals to `authorized_principals` file.

```shell
echo "admin" > /etc/ssh/authorized_principals/root
```

Reload sshd service after file changes.

## Client configuration

Save the SSH CA public key to `~/.ssh/known_hosts` file to your computer.

```
@cert-authority * ssh-rsa ...
```

Now your computer trust SSH CA Host Certificate when connect to SSH when you connect to service. This is important because the Host Certificate will change everytime you redeploy container.

## Sign client public key with SSH CA

Finally you can now sign your Host Public key with SSH CA Certificate. Change file name `id_rsa-cert.pub` to your public key name if it's different than default.

```shell
ssh username@container_ip "sudo /usr/local/bin/sign-ssh-user-cert.sh" > ~/.ssh/id_rsa-cert.pub
```

And now you should able access to `root` use of server with SSH CA signed public keypair. 