ARG ROUNDCUBE_VER=1.3.4
ARG ADMIN_VER=1.0
ARG PHP_VER=7.2

FROM jeboehm/mailserver-admin:${ADMIN_VER} AS admin

FROM jwilder/dockerize:0.6.0 AS dockerize

FROM roundcube/roundcubemail:${ROUNDCUBE_VER} AS roundcube

FROM jeboehm/php-nginx-base:${PHP_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

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
    ADMIN_USERS="admin@example.com" \
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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
