FROM alpine:3.4
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
    && wget -q -O- https://github.com/sstephenson/bats/archive/v$BATSVERSION.tar.gz | tar -xzv \
    && ./bats-$BATSVERSION/install.sh /usr/local \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/v$IMAPTESTERVERSION/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && rm -rf /bats-$BATSVERSION \
    && postconf smtputf8_enable=no

COPY rootfs/ /

CMD ["sh"]
