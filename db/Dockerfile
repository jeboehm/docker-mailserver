FROM mysql:5.7
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MYSQL_ROOT_PASSWORD=changeme

COPY rootfs/ /
RUN rm -rf /var/log/*
