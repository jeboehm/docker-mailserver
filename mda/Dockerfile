FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

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
    SSL_KEY=/media/tls/mailserver.key

RUN apk --no-cache add \
         dovecot \
         dovecot-mysql \
         dovecot-pigeonhole-plugin \
    && adduser -h /var/vmail -u 5000 -D vmail \
    && rm -rf /etc/ssl/dovecot

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /
RUN sievec /etc/dovecot/sieve-after/spam-to-folder.sieve

EXPOSE 2003 9000 4190 143 110 993 995
VOLUME ["/var/vmail"]

CMD ["/usr/local/bin/entrypoint.sh"]
