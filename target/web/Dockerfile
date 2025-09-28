FROM php:8.4-fpm-alpine@sha256:c4e122105b22e71ca28d5db60223a331d77473f52ec6a1d7d69c6d612ef9b2c2

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ARG EXTENSION_INSTALLER_VER=2.9.8 # renovate: depName=mlocati/docker-php-extension-installer
RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/download/${EXTENSION_INSTALLER_VER}/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
        @composer \
        apcu \
        intl \
        opcache \
        pdo_mysql \
        redis \
        zip && \
    rm /usr/local/bin/install-php-extensions

RUN apk add --no-cache \
        nginx \
        supervisor && \
    rm /etc/nginx/nginx.conf && \
    rm -r /etc/nginx/http.d/

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD= \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    FILTER_WEB_ADDRESS=filter:11334 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_MANAGESIEVE_ADDRESS=mda:4190 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    WEB_HTTP_ADDRESS=web:8080 \
    WEB_PHP_ADDRESS=127.0.0.1:9000 \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    MAILNAME=mail.example.com \
    LABEL=docker-mailserver \
    LABEL_SHORT=docker-mailserver \
    APP_ENV=prod \
    TRUSTED_PROXIES=172.16.0.0/12 \
    DOCTRINE_DEPRECATIONS=track \
    WAITSTART_TIMEOUT=1m \
    ADMIN_VER=${ADMIN_VER} \
    DATABASE_URL="mysql://%env(MYSQL_USER)%:%env(MYSQL_PASSWORD)%@%env(MYSQL_HOST)%:%env(MYSQL_PORT)%/%env(MYSQL_DATABASE)%?serverVersion=8.4" \
    COMPOSER_ALLOW_SUPERUSER=1

ARG RC_PLUGINS=""
COPY --from=docker.io/roundcube/roundcubemail:1.6.11-fpm@sha256:c7ca21fc0d617e1b866f112250a2b9638a0e237d5a0b345c7b74258ef8fba704 /usr/src/roundcubemail/ /var/www/html/webmail/
WORKDIR /var/www/html/webmail
RUN --mount=type=cache,target=/root/.composer \
    mkdir -p \
        temp/ \
        logs/ && \
    chown -R www-data:www-data \
        temp/ \
        logs/ && \
    mv composer.json-dist composer.json && \
    if [ "${RC_PLUGINS}" != "" ]; then \
        composer require \
        --ignore-platform-reqs --prefer-dist --prefer-stable \
        --no-interaction --optimize-autoloader --apcu-autoloader \
        ${RC_PLUGINS}; \
    fi

ARG ADMIN_VER=5.5.1 # renovate: depName=jeboehm/mailserver-admin
WORKDIR /opt/manager
RUN --mount=type=cache,target=/root/.composer \
    curl -sSLf \
        -o /tmp/admin.tar.gz \
        https://github.com/jeboehm/mailserver-admin/archive/${ADMIN_VER}.tar.gz && \
    tar -xf /tmp/admin.tar.gz --strip=1 && \
    rm /tmp/admin.tar.gz && \
    mkdir -p \
        var/cache/ \
        var/log/ && \
    DATABASE_URL="${DATABASE_URL}?serverVersion=8.0" composer install --no-dev --prefer-dist -o --apcu-autoloader && \
    composer symfony:dump-env prod && \
    chown -R www-data:www-data \
        var/cache/prod/ \
        var/log/ && \
    ln -s /opt/manager/public /var/www/html/manager

WORKDIR /
COPY --from=ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /
RUN chown -R www-data /var/www/html/autoconfig /etc/nginx /var/lib/nginx

USER www-data

HEALTHCHECK CMD curl -s http://127.0.0.1:8080/login | grep docker-mailserver
EXPOSE 8080
CMD ["/usr/local/bin/entrypoint.sh"]
