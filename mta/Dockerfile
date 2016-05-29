FROM alpine:3.3
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MAILNAME mail.example.com
ENV MYNETWORKS 172.17.0.0/16 127.0.0.0/8
ENV MYSQL_HOST db
ENV MYSQL_USER root
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DBNAME mailserver

RUN apk --no-cache add postfix-mysql postfix rsyslog
RUN touch /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf \
    /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-email2email.cf && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf myhostname=$MAILNAME && \
    postconf mynetworks="$MYNETWORKS" && \
    chgrp postfix /etc/postfix/mysql-*.cf && \
    chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf

ADD config/ /config
ADD entrypoint.sh /entrypoint.sh

EXPOSE 25
VOLUME /var/spool/postfix

CMD ["/entrypoint.sh"]
