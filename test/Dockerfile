FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    WAITSTART_TIMEOUT=1m

RUN apk --no-cache add \
      bash \
      bats \
      curl \
      mariadb-client \
      openssl \
      perl \
      perl-net-ssleay \
      php5 \
      php5-imap \
    && adduser -u 5000 -s /bin/sh -D tester \
    && wget -q -O /usr/local/bin/swaks https://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks \
    && chmod +x /usr/local/bin/swaks \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/v0.1.1/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && ln -s /usr/bin/php5 /usr/bin/php \
    && mkdir -p /usr/share/tests/resources/ \
    && wget -q -O /usr/share/tests/resources/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt \
    && wget -q -O /usr/share/tests/resources/eicar.com https://secure.eicar.org/eicar.com

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

USER tester
CMD ["/usr/local/bin/run-tests.sh"]
