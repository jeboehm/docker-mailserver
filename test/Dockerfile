FROM jwilder/dockerize:0.6.1 AS dockerize
FROM alpine:3.16

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    WAITSTART_TIMEOUT=1m

# Iconv fix: https://github.com/docker-library/php/issues/240#issuecomment-305038173
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ gnu-libiconv
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

ARG IMAPTESTER_VER=v1.2.0 # renovate: depName=jeboehm/imap-tester

RUN apk --no-cache add \
      bash \
      bats \
      curl \
      docker \
      jq \
      mariadb-client \
      openssl \
      perl \
      perl-net-ssleay \
      php8 \
      php8-dom \
      php8-fileinfo \
      php8-mbstring \
      php8-iconv \
      php8-phar \
      php8-iconv \
      php8-openssl \
    && wget -q -O /usr/local/bin/swaks https://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks \
    && chmod +x /usr/local/bin/swaks \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/${IMAPTESTER_VER}/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && mkdir -p /usr/share/fixtures \
    && wget -q -O /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt \
    && wget -q -O /usr/share/fixtures/eicar.com https://secure.eicar.org/eicar.com

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

CMD ["/usr/local/bin/run-tests.sh"]
