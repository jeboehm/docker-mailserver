FROM ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb AS dockerize
FROM alpine:3.23

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_DATABASE=mailserver \
    FILTER_WEB_ADDRESS=filter:11334 \
    IS_KUBERNETES=0 \
    KUBECTL_CONFIG=/tmp/kubeconfig \
    MDA_POP3_ADDRESS=mda:31110 \
    MDA_IMAP_ADDRESS=mda:31143 \
    MDA_POP3S_ADDRESS=mda:31995 \
    MDA_IMAPS_ADDRESS=mda:31993 \
    MTA_SMTP_ADDRESS=mta:25 \
    MTA_SMTP_SUBMISSION_ADDRESS=mta:587 \
    RELAYHOST=false \
    UNBOUND_DNS_ADDRESS=unbound:5353 \
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
      kubectl \
      mariadb-client \
      mariadb-connector-c \
      openssl \
      perl \
      perl-net-ssleay \
      php84 \
      php84-dom \
      php84-fileinfo \
      php84-mbstring \
      php84-iconv \
      php84-phar \
      php84-iconv \
      php84-openssl \
      php84-tokenizer \
      redis \
    && ln -sf /usr/bin/php84 /usr/bin/php \
    && wget -q -O /usr/local/bin/imap-tester https://github.com/jeboehm/imap-tester/releases/download/${IMAPTESTER_VER}/imap-tester.phar \
    && chmod +x /usr/local/bin/imap-tester \
    && mkdir -p /usr/share/fixtures \
    && wget -q -O /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ swaks=20240103.0-r0

COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

WORKDIR /app/tests
COPY integration/ /app/tests/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bats", "."]
