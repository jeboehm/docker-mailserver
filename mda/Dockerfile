ARG DOCKERIZE_VER=0.6.0
ARG ALPINE_VER=3.9

FROM jwilder/dockerize:${DOCKERIZE_VER} AS dockerize

FROM alpine:${ALPINE_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    MAILNAME=mail.example.com \
    POSTMASTER=postmaster@example.com \
    SUBMISSION_HOST=mta \
    ENABLE_POP3=true \
    ENABLE_IMAP=true \
    SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key \
    WAITSTART_TIMEOUT=1m

RUN apk --no-cache add \
         curl \
         dovecot \
         dovecot-lmtpd \
         dovecot-mysql \
         dovecot-pigeonhole-plugin \
         dovecot-pop3d \
         dovecot-submissiond && \
    adduser -h /var/vmail -u 5000 -D vmail && \
    rm -rf /etc/ssl/dovecot && \
    openssl dhparam -out /etc/dovecot/dh.pem 2048

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

RUN sievec /etc/dovecot/sieve/global/spam-to-folder.sieve && \
    sievec /etc/dovecot/sieve/global/learn-ham.sieve && \
    sievec /etc/dovecot/sieve/global/learn-spam.sieve

EXPOSE 2003 4190 143 110 993 995
VOLUME ["/var/vmail"]

HEALTHCHECK CMD echo "? LOGOUT" | nc 127.0.0.1 143 | grep "Dovecot ready."
CMD ["/usr/local/bin/entrypoint.sh"]
