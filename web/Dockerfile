ARG ROUNDCUBE_VER=1.3.9-fpm
ARG ADMIN_VER=1.3.5
ARG PHP_VER=7.2
ARG DOCKERIZE_VER=0.6.0

FROM jeboehm/mailserver-admin:${ADMIN_VER} AS admin

FROM jwilder/dockerize:${DOCKERIZE_VER} AS dockerize

FROM roundcube/roundcubemail:${ROUNDCUBE_VER} AS roundcube

FROM jeboehm/php-nginx-base:${PHP_VER}

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
    WAITSTART_TIMEOUT=1m

COPY --from=admin /var/www/html/ /opt/manager/
COPY --from=roundcube /usr/src/roundcubemail/ /var/www/html/webmail/
COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

RUN ln -s /opt/manager/public /var/www/html/manager && \
    chown -R www-data \
        /opt/manager/var/cache/ \
        /opt/manager/var/log/ \
        /var/www/html/webmail/temp/ \
        /var/www/html/webmail/logs/

HEALTHCHECK CMD curl -s http://127.0.0.1/ | grep docker-mailserver
CMD ["/usr/local/bin/entrypoint.sh"]
