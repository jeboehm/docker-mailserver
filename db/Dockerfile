FROM mariadb:11
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MYSQL_ROOT_PASSWORD=changeme

COPY rootfs/ /
VOLUME /run/mysqld
