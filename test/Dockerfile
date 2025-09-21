FROM ghcr.io/jeboehm/dockerize:0.9.3 AS dockerize
FROM alpine:3.21

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD= \
    MYSQL_DATABASE=mailserver \
    WAITSTART_TIMEOUT=1m \
    POP3_ADDRESS=mda:31110 \
    IMAP_ADDRESS=mda:31143 \
    POP3S_ADDRESS=mda:31995 \
    IMAPS_ADDRESS=mda:31993 \
    SMTP_ADDRESS=mta:25 \
    SMTP_SUBMISSION_ADDRESS=mta:587 \
    WEB_HTTP_ADDRESS=web:8080 \
    FILTER_WEB_ADDRESS=filter:11334

ARG IMAPTESTER_VER=v1.3.0 # renovate: depName=jeboehm/imap-tester

RUN apk --no-cache add \
      bash \
      bats \
      bats-assert \
      bats-support \
      curl \
      docker \
      jq \
      mariadb-client \
      mariadb-connector-c \
      openssl \
      perl \
      perl-net-ssleay \
      php82 \
      php82-dom \
      php82-fileinfo \
      php82-mbstring \
      php82-iconv \
      php82-phar \
      php82-iconv \
      php82-openssl \
      php82-tokenizer \
      redis \
    && ln -sf /usr/bin/php82 /usr/bin/php \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/${IMAPTESTER_VER}/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && mkdir -p /usr/share/fixtures \
    && wget -q -O /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ swaks=20240103.0-r0

COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

CMD ["/usr/local/bin/run-tests.sh"]
