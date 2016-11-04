FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    MAILNAME=mail.example.com \
    POSTMASTER=postmaster@example.com

RUN apk --no-cache add dovecot dovecot-mysql dovecot-pigeonhole-plugin \
    && adduser -h /var/vmail -u 5000 -D vmail \
    && rm -rf /etc/ssl/dovecot/ \
         /etc/dovecot/conf.d/15-lda.conf \
         /etc/dovecot/dovecot-sql.conf.ext \
         /run \
         /var/lib/dovecot \
    && ln -sf /etc/dovecot/rw/15-lda.conf /etc/dovecot/conf.d/15-lda.conf \
    && ln -sf /etc/dovecot/rw/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext \
    && ln -sf /tmp /run \
    && ln -sf /tmp /var/lib/dovecot

COPY rootfs/ /
RUN sievec /etc/dovecot/sieve-after/spam-to-folder.sieve

EXPOSE 2003 9000 4190 143 110 993 995
VOLUME ["/var/vmail", "/etc/dovecot/rw"]

CMD ["/usr/local/bin/entrypoint.sh"]
