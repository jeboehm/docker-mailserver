FROM php:7.0-apache
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MANAGER_URL=http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz \
    WEBMAIL_URL=http://github.com/roundcube/roundcubemail/releases/download/1.2.0/roundcubemail-1.2.0.tar.gz

RUN docker-php-ext-install mysqli pdo_mysql \
    && apt-get update && apt-get install --no-install-recommends -y wget git unzip \
    && wget -q https://getcomposer.org/download/1.1.2/composer.phar -O /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

WORKDIR /var/www/html/manager
RUN wget -q -O- $MANAGER_URL | tar zx \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

WORKDIR /var/www/html/webmail
RUN wget -q -O- --no-check-certificate $WEBMAIL_URL | tar --strip 1 -zx \
    && chmod 777 logs temp \
    && mv composer.json-dist composer.json \
    && composer install

WORKDIR /var/www/html
COPY rootfs/ ./
