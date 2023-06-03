FROM php:8.1.19RC1-cli-alpine

# Install OpenSSH server and PHP PDO MySQL
RUN apk --no-cache add openssh bash sudo gettext moreutils \
    && docker-php-ext-install pdo pdo_mysql

COPY sshd_config /etc/ssh/sshd_config
COPY scripts/. /usr/local/bin
RUN chmod 700 /usr/local/bin/*.sh
RUN chmod 700 /usr/local/bin/*.php

RUN echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/sign-ssh-user-cert.sh" | EDITOR='tee -a' visudo

COPY docker-entrypoint.sh /
RUN chmod 744 docker-entrypoint.sh
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
CMD [ "/usr/sbin/sshd", "-D", "-e" ]