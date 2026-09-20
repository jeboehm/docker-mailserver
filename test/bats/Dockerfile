FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV DB_DRIVER=mysql \
    DB_HOST=db \
    DB_PORT=3306 \
    DB_USER=root \
    DB_NAME=mailserver \
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
ARG SWAKS_VER=v20240103.0 # renovate: depName=jetmore/swaks

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
      postgresql17-client \
      netcat-openbsd \
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
    && wget -q -O /tmp/swaks.tar.gz https://github.com/jetmore/swaks/releases/download/${SWAKS_VER}/swaks-${SWAKS_VER#v}.tar.gz \
    && tar -xzf /tmp/swaks.tar.gz -C /tmp \
    && install -m 0755 -o root -g root /tmp/swaks-${SWAKS_VER#v}/swaks /usr/local/bin/swaks \
    && rm -rf /tmp/swaks.tar.gz /tmp/swaks-${SWAKS_VER#v} \
    && swaks --version \
    && mkdir -p /usr/share/fixtures \
    && wget -q -O /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt

COPY rootfs/ /

WORKDIR /app/tests
COPY integration/ /app/tests/

# bats writes the JUnit report here; docker-compose.test.yml bind-mounts the
# directory to ./test/report so that CI can upload it.
RUN mkdir -p /app/report

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bats", "--timing", "--print-output-on-failure", "--report-formatter", "junit", "--output", "/app/report", "."]
