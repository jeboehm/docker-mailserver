FROM ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb AS dockerize
FROM alpine:3.22@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD= \
    MYSQL_DATABASE=mailserver \
    FILTER_WEB_ADDRESS=filter:11334 \
    IS_KUBERNETES=0 \
    MDA_POP3_ADDRESS=mda:31110 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_POP3S_ADDRESS=mda:31995 \
    MDA_IMAPS_ADDRESS=mda:31993 \
    MTA_SMTP_ADDRESS=mta:25 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    UNBOUND_DNS_ADDRESS=unbound:53 \
    WAITSTART_TIMEOUT=1m \
    WEB_HTTP_ADDRESS=web:8080

ARG IMAPTESTER_VER=v1.3.0 # renovate: depName=jeboehm/imap-tester

RUN apk --no-cache add \
      bash \
      bats \
      bats-assert \
      bats-support \
      bind-tools \
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
COPY _helpers/ /usr/local/bin/

WORKDIR /app/tests
COPY integration/ /app/tests/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bats", "."]
