FROM alpine:3.6
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    MAILNAME=mail.example.com \
    POSTMASTER=postmaster@example.com \
    DOCKERIZE_VERSION=v0.5.0 \
    SUBMISSION_HOST=mta \
    ENABLE_POP3=true \
    ENABLE_IMAP=true

RUN apk --no-cache add \
         dovecot \
         dovecot-mysql \
         dovecot-pigeonhole-plugin \
         openssl \
    && adduser -h /var/vmail -u 5000 -D vmail \
    && rm -rf /etc/ssl/dovecot \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY rootfs/ /
RUN sievec /etc/dovecot/sieve-after/spam-to-folder.sieve

EXPOSE 2003 9000 4190 143 110 993 995
VOLUME ["/var/vmail"]

CMD ["/usr/local/bin/entrypoint.sh"]
