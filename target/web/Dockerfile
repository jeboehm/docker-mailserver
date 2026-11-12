FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS base

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

# RSPAMD_PASSWORD and DATABASE_URL only hold %env()% references that Symfony
# resolves at runtime; the credentials themselves are never part of the image.
# hadolint ignore=DL3064
ENV DB_DRIVER=mysql \
    DB_HOST=db \
    DB_PORT=3306 \
    DB_NAME=mailserver \
    DB_USER=mailserver \
    DB_SERVER_VERSION=8.4 \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    APP_SHARE_DIR="var/cache" \
    DATABASE_URL="%env(DB_DRIVER)%://%env(DB_USER)%:%env(DB_PASSWORD)%@%env(DB_HOST)%:%env(DB_PORT)%/%env(DB_NAME)%?serverVersion=%env(DB_SERVER_VERSION)%" \
    DOVEADM_HTTP_URL="https://%env(MDA_DOVEADM_ADDRESS)%" \
    FILTER_WEB_ADDRESS=filter:11334 \
    MAILNAME=mail.example.com \
    MCP_ENABLED=true \
    MCP_MAIL_READ_ENABLED=true \
    MCP_MAIL_SEND_ENABLED=true \
    MDA_DOVEADM_ADDRESS=mda:8080 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_IMAPS_ADDRESS=mda:31993 \
    MDA_MANAGESIEVE_ADDRESS=mda:4190 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    RSPAMD_CONTROLLER_URL="http://%env(FILTER_WEB_ADDRESS)%" \
    RSPAMD_PASSWORD="%env(CONTROLLER_PASSWORD)%" \
    SERVER_ROOT=/var/www/html \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    WAITSTART_TIMEOUT=1m

ARG FRANKENPHP_VER=v1.13.5 # renovate: depName=php/frankenphp
RUN apk add --no-cache \
        curl && \
    ln -sf /tmp /home/app && \
    ARCH=$(uname -m) && \
    curl -sfOL "https://github.com/php/frankenphp/releases/download/${FRANKENPHP_VER}/frankenphp-linux-${ARCH}" && \
    chmod +x "frankenphp-linux-${ARCH}" && \
    mv "frankenphp-linux-${ARCH}" /usr/bin/frankenphp

RUN printf '#!/bin/sh\nexec frankenphp php-cli "$@"\n' > /usr/bin/php && \
    chmod +x /usr/bin/php

FROM base AS composer

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer/composer:2.11.1@sha256:1b9f7b574c833b0f426129f994ef757b7c7533000b6c93fb60c8c82dd06f16fc --link /usr/bin/composer /usr/bin/composer

FROM composer AS roundcube-builder

ARG RC_PLUGINS=""
ARG RC_VER=1.7.6 # renovate: depName=roundcube/roundcubemail
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
    chmod 777 \
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

ARG ADMIN_VER=5.21.0 # renovate: depName=jeboehm/mailserver-admin
WORKDIR /opt/admin
RUN curl -sSLf \
        -o /tmp/admin.tar.gz \
        https://github.com/jeboehm/mailserver-admin/releases/download/${ADMIN_VER}/release-${ADMIN_VER}.tar.gz && \
    tar -oxf /tmp/admin.tar.gz && \
    rm /tmp/admin.tar.gz && \
    chmod 777 \
        /opt/admin/var/cache \
        /opt/admin/var/log

FROM base AS prod

WORKDIR /
COPY --chown=root:root --from=roundcube-builder --link /opt/roundcube/ /opt/roundcube/
COPY --chown=root:root --from=admin-builder --link /opt/admin/ /opt/admin/
COPY --chown=root:root rootfs/ /

RUN mkdir -p "${SERVER_ROOT}" && \
    ln -s /opt/roundcube/public_html "${SERVER_ROOT}/webmail" && \
    ln -s /opt/admin/public "${SERVER_ROOT}/manager"

RUN adduser -DH -u 1000 app
USER 1000:1000

HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD []
