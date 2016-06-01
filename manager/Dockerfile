FROM php:7.0-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST db
ENV MYSQL_DATABASE mailserver
ENV MYSQL_USER mailserver
ENV MYSQL_PASSWORD changeme
ENV MYSQL_ROOT_PASSWORD changeme

WORKDIR /usr/src/manager
RUN docker-php-ext-install mysqli

RUN wget -q -O- http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz | tar zxv
RUN rm -rf conf/cnf_main_template.php install/ install.php && ln -s login.php index.php
ADD config.php conf/cnf_main.php

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:80"]
