# SSH-CA Signin Service

This is for sign user and assing principals. 

## Generate SSH CA private and public keys

Generate SSH CA private and public keys. Don't set passwords.

```
ssh-keygen -f ssh-ca
```

## Deploy to Swarm

Create Secrets

```
cat ssh-ca | docker secret create ssh_ca_private.key -
```

Deploy stack to Swarm with `docker stack deploy -c docker-compose.yml` command.

```
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
    secrets:
    - ssh_ca_private.key

secrets:
  ssh_ca_private.key:
    external: true
```