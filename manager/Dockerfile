FROM php:7.0-fpm-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MANAGER_URL=http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz

RUN docker-php-ext-install mysqli \
    && wget -q -O- $MANAGER_URL | tar zx \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

COPY config.php conf/cnf_main.php
