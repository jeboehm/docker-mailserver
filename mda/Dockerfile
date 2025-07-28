FROM ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb AS dockerize
FROM alpine:3.21@sha256:b6a6be0ff92ab6db8acd94f5d1b7a6c2f0f5d10ce3c24af348d333ac6da80685

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    MAILNAME=mail.example.com \
    POSTMASTER=postmaster@example.com \
    SUBMISSION_HOST=mta \
    ENABLE_POP3=true \
    ENABLE_IMAP=true \
    ENABLE_FTS=true \
    FILTER_HOST=filter \
    SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key \
    WAITSTART_TIMEOUT=1m \
    RECIPIENT_DELIMITER=- \
    FTS_ARGS="partial=3 full=20 verbose=0 lowmemory=256" \
    FTS_VSZ_LIMIT=256M

RUN apk --no-cache add \
         curl \
         dovecot \
         dovecot-lmtpd \
         dovecot-mysql \
         dovecot-pigeonhole-plugin \
         dovecot-pop3d \
         dovecot-fts-xapian && \
    adduser -h /var/vmail -u 5000 -D vmail && \
    rm -rf /etc/ssl/dovecot && \
    openssl dhparam -out /etc/dovecot/dh.pem 2048

COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

RUN sievec /etc/dovecot/sieve/global/

EXPOSE 2003 2004 4190 143 110 993 995
VOLUME ["/var/vmail"]

HEALTHCHECK CMD echo "? LOGOUT" | nc 127.0.0.1 143 | grep "Dovecot ready."
CMD ["/usr/local/bin/entrypoint.sh"]
