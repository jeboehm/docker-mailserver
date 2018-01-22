ARG PHP_VER=7.1
FROM jeboehm/php-nginx-base:${PHP_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MANAGER_URL=http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz \
    WEBMAIL_URL=https://github.com/roundcube/roundcubemail/releases/download/1.2.4/roundcubemail-1.2.4-complete.tar.gz \
    DOCKERIZE_VERSION=v0.5.0 \
    MTA_HOST=mta \
    MDA_HOST=mda \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /var/www/html/manager
RUN wget -q -O- $MANAGER_URL | tar -zx \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

WORKDIR /var/www/html/webmail
RUN wget -q -O- $WEBMAIL_URL | tar --strip 1 -zx \
    && rm -rf installer/ temp/ logs/

WORKDIR /var/www/html
COPY rootfs/ /

CMD ["/usr/local/bin/entrypoint.sh"]
