FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db
    MYSQL_USER=root
    MYSQL_PASSWORD=changeme
    MYSQL_DATABASE=mailserver
    MAILNAME=mail.example.com
    POSTMASTER=postmaster@example.com

RUN apk --no-cache add dovecot dovecot-mysql rsyslog dovecot-pigeonhole-plugin \
    && adduser -h /var/vmail -u 5000 -D vmail \
    && rm -rf /etc/ssl/dovecot/ \
    && tar -cf /config.tar /etc/dovecot/

COPY patch/ /patch/
COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /usr/local/bin/

EXPOSE 9000 9001 143 110 993 995
VOLUME /var/vmail

CMD ["/entrypoint.sh"]
