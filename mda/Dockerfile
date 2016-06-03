FROM alpine:3.3
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST db
ENV MYSQL_USER root
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DATABASE mailserver
ENV MAILNAME mail.example.com
ENV POSTMASTER postmaster@example.com

RUN apk --no-cache add dovecot dovecot-mysql rsyslog
RUN adduser -h /var/vmail -u 5000 -D vmail
RUN rm /etc/ssl/dovecot/server.key
RUN tar -cf /config.tar /etc/dovecot/

ADD patch/ /patch
ADD entrypoint.sh /entrypoint.sh
ADD scripts/ /usr/local/bin/

EXPOSE 9000 9001 143 110 993 995
VOLUME /var/vmail

CMD ["/entrypoint.sh"]
