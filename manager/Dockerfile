FROM php:7.0-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme

WORKDIR /usr/src/manager
RUN docker-php-ext-install mysqli

RUN wget -q -O- http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz | tar zxv \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

COPY config.php conf/cnf_main.php

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:80"]
