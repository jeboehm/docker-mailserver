ARG DOCKERIZE_VER=0.6.0
ARG ALPINE_VER=3.9

FROM jwilder/dockerize:${DOCKERIZE_VER} AS dockerize
FROM alpine:${ALPINE_VER}

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    WAITSTART_TIMEOUT=1m

# Iconv fix: https://github.com/docker-library/php/issues/240#issuecomment-305038173
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ gnu-libiconv
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

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
      php7 \
      php7-imap \
      php7-phar \
      php7-iconv \
      php7-openssl \
    && wget -q -O /usr/local/bin/swaks https://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks \
    && chmod +x /usr/local/bin/swaks \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/v0.2.1/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && mkdir -p /usr/share/fixtures \
    && wget -q -O /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt \
    && wget -q -O /usr/share/fixtures/eicar.com https://secure.eicar.org/eicar.com

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

CMD ["/usr/local/bin/run-tests.sh"]
