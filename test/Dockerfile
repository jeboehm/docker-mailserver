FROM alpine:3.6
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    SWAKSURL=http://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks \
    IMAPTESTERVERSION=0.1.1 \
    BATSVERSION=0.4.0

RUN apk --no-cache add \
      bash \
      bats \
      curl \
      mariadb-client \
      openssl \
      perl \
      perl-net-ssleay \
      postfix \
      php5 \
      php5-imap \
    && wget -q -O /usr/local/bin/swaks ${SWAKSURL} \
    && chmod +x /usr/local/bin/swaks \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/v$IMAPTESTERVERSION/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && postconf smtputf8_enable=no \
    && ln -s /usr/bin/php5 /usr/bin/php

COPY rootfs/ /

CMD ["sh"]
