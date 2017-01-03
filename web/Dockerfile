FROM php:7.1-fpm-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=changeme \
    MANAGER_URL=http://www.grs-service.ch/pub/grs_mgr_v3-03_jessie_with_php7_setup.tgz \
    WEBMAIL_URL=http://github.com/roundcube/roundcubemail/releases/download/1.2.3/roundcubemail-1.2.3.tar.gz

RUN apk --no-cache add \
      nginx \
      supervisor \
      wget \
      ca-certificates \
      libmcrypt-dev \
      libpng-dev && \
    docker-php-ext-install -j4 \
      mcrypt \
      zip \
      mysqli \
      pdo_mysql && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -s /usr/local/bin/php /usr/bin/php && \
    rm -rf /var/lib/nginx/tmp && \
    ln -sf /tmp /var/lib/nginx/tmp && \
    update-ca-certificates

WORKDIR /var/www/html/manager
RUN wget -q -O- $MANAGER_URL | tar -zx \
    && rm -rf conf/cnf_main_template.php install/ install.php \
    && ln -s login.php index.php

WORKDIR /var/www/html/webmail
RUN wget -q -O- --no-check-certificate $WEBMAIL_URL | tar --strip 1 -zx \
    && chmod 777 logs temp \
    && pear install mail_mime mail_mimedecode net_smtp net_idna2-beta auth_sasl net_sieve crypt_gpg \
    && rm -rf installer/

WORKDIR /var/www/html
COPY rootfs/ /

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
