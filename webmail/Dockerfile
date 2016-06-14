FROM php:7.0-fpm-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    WEBMAIL_VERSION=1.2.0

RUN apk --no-cache add wget tar \
    && docker-php-ext-install mysqli \
    && wget -q -O- --no-check-certificate http://github.com/roundcube/roundcubemail/releases/download/$WEBMAIL_VERSION/roundcubemail-$WEBMAIL_VERSION.tar.gz | tar --strip 1 -zx \
    && apk --no-cache del wget tar

COPY rootfs/ /var/www/html/
