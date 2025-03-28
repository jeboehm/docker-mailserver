FROM jwilder/dockerize:v0.9.3 AS dockerize
FROM roundcube/roundcubemail:1.6.x-fpm AS roundcube
FROM composer:2.8 AS composer
FROM php:8.3-fpm-alpine

ARG ADMIN_VER=5.0.5 # renovate: depName=jeboehm/mailserver-admin

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

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

COPY --from=roundcube /usr/src/roundcubemail/ /var/www/html/webmail/
COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY --from=composer /usr/bin/composer /usr/bin/composer

# shellcheck disable=SC2086
RUN apk add --no-cache \
        acl \
        icu \
        icu-dev \
        libzip \
        libzip-dev \
        nginx \
        supervisor && \
    apk add --no-cache --virtual .phpize-deps ${PHPIZE_DEPS} && \
    pecl install apcu && \
    pecl install redis && \
    docker-php-ext-install -j5 \
        intl \
        opcache \
        pdo_mysql \
        zip && \
    docker-php-ext-enable apcu && \
    docker-php-ext-enable redis && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    apk del --no-cache \
        icu-dev \
        libzip-dev \
        .phpize-deps

COPY rootfs/ /

WORKDIR /opt/manager

RUN wget -O /tmp/admin.tar.gz -q https://github.com/jeboehm/mailserver-admin/archive/${ADMIN_VER}.tar.gz && \
    tar -xf /tmp/admin.tar.gz -C /opt/manager --strip=1 && \
    rm /tmp/admin.tar.gz && \
    mkdir -p \
        /opt/manager/var/cache \
        /opt/manager/var/log && \
    setfacl -dR -m u:"www-data":rwX \
        /opt/manager/var/cache/ \
        /opt/manager/var/log/ \
        /var/www/html/webmail/temp/ \
        /var/www/html/webmail/logs/ && \
    DATABASE_URL="${DATABASE_URL}?serverVersion=8.0" composer install --no-dev --prefer-dist -o --apcu-autoloader && \
    composer symfony:dump-env prod && \
    ln -s /opt/manager/public /var/www/html/manager

WORKDIR /var/www/html

ARG RC_PLUGINS ""
ENV RC_PLUGINS $RC_PLUGINS

RUN mv /var/www/html/webmail/composer.json-dist /var/www/html/webmail/composer.json && \
    /usr/local/bin/install_roundcube_plugins.sh

HEALTHCHECK CMD curl -s http://127.0.0.1/login | grep docker-mailserver
EXPOSE 80
CMD ["/usr/local/bin/entrypoint.sh"]
