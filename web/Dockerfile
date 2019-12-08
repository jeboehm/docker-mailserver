ARG ROUNDCUBE_VER=1.4.1-fpm
ARG PHP_VER=7.4
ARG DOCKERIZE_VER=0.6.0

FROM jwilder/dockerize:${DOCKERIZE_VER} AS dockerize

FROM roundcube/roundcubemail:${ROUNDCUBE_VER} AS roundcube

FROM jeboehm/php-nginx-base:${PHP_VER}

ARG ADMIN_VER=1.4.1

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MTA_HOST=mta \
    MDA_HOST=mda \
    FILTER_HOST=filter \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    APP_ENV=prod \
    TRUSTED_PROXIES=172.16.0.0/12 \
    WAITSTART_TIMEOUT=1m \
    ADMIN_VER=${ADMIN_VER}

COPY --from=roundcube /usr/src/roundcubemail/ /var/www/html/webmail/
COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

WORKDIR /opt/manager

RUN wget -O /tmp/admin.tar.gz -q https://github.com/jeboehm/mailserver-admin/archive/${ADMIN_VER}.tar.gz && \
    tar -xf /tmp/admin.tar.gz -C /opt/manager --strip=1 && \
    rm /tmp/admin.tar.gz && \
    composer install --no-dev -o

RUN ln -s /opt/manager/public /var/www/html/manager && \
    chown -R www-data \
        /opt/manager/var/cache/ \
        /opt/manager/var/log/ \
        /var/www/html/webmail/temp/ \
        /var/www/html/webmail/logs/

WORKDIR /var/www/html
HEALTHCHECK CMD curl -s http://127.0.0.1/ | grep docker-mailserver
CMD ["/usr/local/bin/entrypoint.sh"]
