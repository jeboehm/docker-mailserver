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
      redis \
    # curl is the SMTP, IMAP and POP3 client of the tests (_helper.bash); a
    # protocol-reduced build would only fail at test time otherwise.
    && curl --version | grep -qE 'imaps.* pop3s.* smtps' \
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
