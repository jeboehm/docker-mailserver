FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

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
    && case "$(curl --version)" in *" imaps "*" pop3s "*" smtps "*) ;; *) echo "curl lacks the mail protocols" >&2 && exit 1 ;; esac \
    && mkdir -p /usr/share/fixtures \
    && curl -fsSL -o /usr/share/fixtures/gtube.txt https://spamassassin.apache.org/gtube/gtube.txt

COPY rootfs/ /

WORKDIR /app/tests
COPY integration/ /app/tests/

# bats writes the JUnit report here; docker-compose.test.yml bind-mounts the
# directory to ./test/report so that CI can upload it.
RUN mkdir -p /app/report

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bats", "--timing", "--print-output-on-failure", "--report-formatter", "junit", "--output", "/app/report", "."]
