FROM alpine:3.22@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS base

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    FILTER_WEB_ADDRESS=filter:11334 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_MANAGESIEVE_ADDRESS=mda:4190 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    WEB_HTTP_ADDRESS=web:8080 \
    WEB_PHP_ADDRESS=127.0.0.1:9000 \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    MAILNAME=mail.example.com \
    WAITSTART_TIMEOUT=1m \
    DATABASE_URL="mysql://%env(MYSQL_USER)%:%env(MYSQL_PASSWORD)%@%env(MYSQL_HOST)%:%env(MYSQL_PORT)%/%env(MYSQL_DATABASE)%?serverVersion=8.4" \
    SERVER_ROOT=/var/www/html

ARG FRANKENPHP_VER=v1.11.1 # renovate: depName=php/frankenphp
RUN apk add --no-cache \
        curl && \
    curl -sfOL https://github.com/php/frankenphp/releases/download/${FRANKENPHP_VER}/frankenphp-linux-x86_64 && \
    chmod +x frankenphp-linux-x86_64 && \
    mv frankenphp-linux-x86_64 /usr/bin/frankenphp && \
    mkdir -p ${SERVER_ROOT} && \
    ln -sf /tmp /home/app && \
    apk del --no-cache apk-tools

RUN printf '#!/bin/sh\nexec frankenphp php-cli "$@"\n' > /usr/bin/php && \
    chmod +x /usr/bin/php

FROM base AS composer

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer/composer:2.9.2@sha256:969fb900253c0e71645cf74257d6c9206304573e8b246d1bc57f8ac1d64e12f4 /usr/bin/composer /usr/local/bin/composer

FROM composer AS roundcube-builder

ARG RC_PLUGINS=""
ARG RC_VER=1.7-beta2 # renovate: depName=roundcube/roundcubemail
WORKDIR /opt/roundcube
RUN --mount=type=cache,target=/root/.composer \
    curl -sSLf \
        -o /tmp/webmail.tar.gz \
        https://github.com/roundcube/roundcubemail/releases/download/${RC_VER}/roundcubemail-${RC_VER}-complete.tar.gz && \
    tar -oxf /tmp/webmail.tar.gz --strip=1 && \
    rm /tmp/webmail.tar.gz && \
    rm -rf \
        temp/ \
        logs/ && \
    mkdir -p \
        temp/ \
        logs/ && \
    if [ "${RC_PLUGINS}" != "" ]; then \
        composer require \
            --ignore-platform-reqs --prefer-dist --prefer-stable \
            --no-interaction --classmap-authoritative \
            --minimal-changes \
            ${RC_PLUGINS}; \
    fi && \
    composer install \
        --no-dev --prefer-dist \
        --classmap-authoritative --ignore-platform-reqs && \
    rm -f \
        composer.lock \
        public_html/installer.php && \
    find . -type f -name '.htaccess' -delete

FROM composer AS admin-builder

ARG ADMIN_VER=5.12.0 # renovate: depName=jeboehm/mailserver-admin
WORKDIR /opt/admin
RUN curl -sSLf \
        -o /tmp/admin.tar.gz \
        https://github.com/jeboehm/mailserver-admin/releases/download/${ADMIN_VER}/release-${ADMIN_VER}.tar.gz && \
    tar -oxf /tmp/admin.tar.gz --strip=1 && \
    rm /tmp/admin.tar.gz && \
    composer symfony:dump-env prod

FROM base AS prod

WORKDIR /
COPY --chown=root:root --from=roundcube-builder /opt/roundcube/ /opt/roundcube/
COPY --chown=root:root --from=admin-builder /opt/admin/ /opt/admin/
COPY --chown=root:root rootfs/ /

RUN ln -s /opt/roundcube/public_html ${SERVER_ROOT}/webmail && \
    ln -s /opt/admin/public ${SERVER_ROOT}/manager

ARG USER=app
RUN adduser -DH ${USER} && \
	chown -R ${USER}:${USER} \
        /opt/admin/var/cache/prod \
        /opt/admin/var/log \
        /opt/roundcube/logs \
        /opt/roundcube/temp
USER ${USER}

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD []
