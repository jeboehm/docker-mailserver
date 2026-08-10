# Selects how mailserver-admin is obtained:
#   release (default) - download the pinned release tarball from GitHub
#   local             - build from the "admin-src" build context, for developing
#                       mailserver-admin alongside this repository
ARG ADMIN_SOURCE=release

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

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
    MDA_DOVEADM_ADDRESS=mda:8080 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_MANAGESIEVE_ADDRESS=mda:4190 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    RSPAMD_CONTROLLER_URL="http://%env(FILTER_WEB_ADDRESS)%" \
    RSPAMD_PASSWORD="%env(CONTROLLER_PASSWORD)%" \
    SERVER_ROOT=/var/www/html \
    SUPPORT_URL=https://github.com/jeboehm/docker-mailserver \
    WAITSTART_TIMEOUT=1m

ARG FRANKENPHP_VER=v1.12.7 # renovate: depName=php/frankenphp
RUN apk add --no-cache \
        curl && \
    ln -sf /tmp /home/app && \
    ARCH=$(uname -m) && \
    curl -sfOL https://github.com/php/frankenphp/releases/download/${FRANKENPHP_VER}/frankenphp-linux-${ARCH} && \
    chmod +x frankenphp-linux-${ARCH} && \
    mv frankenphp-linux-${ARCH} /usr/bin/frankenphp

RUN printf '#!/bin/sh\nexec frankenphp php-cli "$@"\n' > /usr/bin/php && \
    chmod +x /usr/bin/php

FROM base AS composer

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer/composer:2.10.2@sha256:16988c546890b7078a7a1415f535caab8f25fd6158de40a99d35dc60c11a77fb --link /usr/bin/composer /usr/bin/composer

FROM composer AS roundcube-builder

ARG RC_PLUGINS=""
ARG RC_VER=1.7.3 # renovate: depName=roundcube/roundcubemail
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

FROM composer AS admin-release

ARG ADMIN_VER=5.17.36 # renovate: depName=jeboehm/mailserver-admin
WORKDIR /opt/admin
RUN curl -sSLf \
        -o /tmp/admin.tar.gz \
        https://github.com/jeboehm/mailserver-admin/releases/download/${ADMIN_VER}/release-${ADMIN_VER}.tar.gz && \
    tar -oxf /tmp/admin.tar.gz && \
    rm /tmp/admin.tar.gz && \
    chmod 777 \
        /opt/admin/var/cache \
        /opt/admin/var/log

# Reproduces the steps of mailserver-admin's own release workflow against a
# working copy provided as the "admin-src" build context. Only built when
# ADMIN_SOURCE=local, see docs/development/mailserver-admin.md.
FROM composer AS admin-local

# sqlite keeps asset-map:compile and dump-env from needing a real database,
# matching what the upstream release workflow does.
ENV APP_ENV=prod \
    DATABASE_URL="sqlite:///%kernel.project_dir%/var/app.db"
WORKDIR /opt/admin

# Dependencies first, so editing application code does not invalidate them.
# hadolint ignore=DL3022
COPY --from=admin-src composer.json composer.lock symfony.lock importmap.php ./
RUN --mount=type=cache,target=/root/.composer \
    composer install --no-progress --prefer-dist -a --no-dev --no-scripts

# hadolint ignore=DL3022
COPY --from=admin-src . ./
# Composer's auto-scripts are skipped: flex resolves the console through
# PHP_BINARY, which is the frankenphp binary rather than the php shim, and
# frankenphp rejects a script path as a subcommand. Running the same commands
# through the shim works.
RUN --mount=type=cache,target=/root/.composer \
    composer install --no-progress --prefer-dist -a --no-dev --no-scripts && \
    php bin/console importmap:install && \
    php bin/console assets:install --symlink --relative public && \
    php bin/console asset-map:compile && \
    composer dump-env prod && \
    rm -rf \
        .php-cs-fixer.dist.php \
        _coverage/ \
        assets/ \
        bin/phpunit \
        composer.lock \
        devenv.* \
        phpstan.dist.neon \
        phpunit.dist.xml \
        rector.php \
        renovate.json \
        symfony.lock \
        tests/ \
        tls/ \
        var/ && \
    mkdir -p \
        var/cache \
        var/log && \
    chmod 777 \
        /opt/admin/var/cache \
        /opt/admin/var/log

# Resolves to either admin-release or admin-local.
# hadolint ignore=DL3006
FROM admin-${ADMIN_SOURCE} AS admin-builder

FROM base AS prod

WORKDIR /
COPY --chown=root:root --from=roundcube-builder --link /opt/roundcube/ /opt/roundcube/
COPY --chown=root:root --from=admin-builder --link /opt/admin/ /opt/admin/
COPY --chown=root:root rootfs/ /

RUN mkdir -p ${SERVER_ROOT} && \
    ln -s /opt/roundcube/public_html ${SERVER_ROOT}/webmail && \
    ln -s /opt/admin/public ${SERVER_ROOT}/manager

ARG USER=app
RUN adduser -DH ${USER}
USER ${USER}

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD []
