ARG ROUNDCUBE_VER=latest
ARG PHP_VER=7.1

FROM jwilder/dockerize:0.6.0 AS dockerize

FROM roundcube/roundcubemail:${ROUNDCUBE_VER} AS roundcube

FROM jeboehm/php-nginx-base:${PHP_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MANAGER_URL=http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz \
    MTA_HOST=mta \
    MDA_HOST=mda \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver

WORKDIR /var/www/html/manager
RUN wget -q -O- $MANAGER_URL | tar -zx \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

COPY --from=roundcube /usr/src/roundcubemail/ /var/www/html/webmail/

WORKDIR /var/www/html

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

CMD ["/usr/local/bin/entrypoint.sh"]
