FROM php:8.4-fpm-alpine@sha256:983b2d9668d50e0b9d346d03290e7296537d10941c4a954af8d62ea5fc9ca463

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ARG EXTENSION_INSTALLER_VER=2.8.5 # renovate: depName=mlocati/docker-php-extension-installer
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
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    MTA_HOST=mta \
    MDA_HOST=mda \
    FILTER_HOST=filter \
    WEB_HOST=web \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    MAILNAME=mail.example.com \
    LABEL=docker-mailserver \
    LABEL_SHORT=docker-mailserver \
    APP_ENV=prod \
    TRUSTED_PROXIES=172.16.0.0/12 \
    WAITSTART_TIMEOUT=1m \
    ADMIN_VER=${ADMIN_VER} \
    DATABASE_URL="mysql://%env(MYSQL_USER)%:%env(MYSQL_PASSWORD)%@%env(MYSQL_HOST)%:%env(MYSQL_PORT)%/%env(MYSQL_DATABASE)%" \
    COMPOSER_ALLOW_SUPERUSER=1

ARG RC_PLUGINS=""
COPY --from=docker.io/roundcube/roundcubemail:1.6.11-fpm@sha256:cf7ffffe8e905af6b745ac73b7ffe09c5cd5dc6b0823e076de4c3b32f2b4b3b1 /usr/src/roundcubemail/ /var/www/html/webmail/
RUN --mount=type=cache,target=/root/.composer \
    cd /var/www/html/webmail && \
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

ARG ADMIN_VER=5.4.27 # renovate: depName=jeboehm/mailserver-admin
RUN --mount=type=cache,target=/root/.composer \
    mkdir /opt/manager && \
    cd /opt/manager && \
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

COPY --from=ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

HEALTHCHECK CMD curl -s http://127.0.0.1/login | grep docker-mailserver
EXPOSE 80
CMD ["/usr/local/bin/entrypoint.sh"]
