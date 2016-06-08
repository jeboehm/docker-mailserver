FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MAILNAME=mail.example.com
    MYNETWORKS=172.17.0.0/16\ 127.0.0.0/8
    MYSQL_HOST=db
    MYSQL_USER=root
    MYSQL_PASSWORD=changeme
    MYSQL_DATABASE=mailserver

RUN apk --no-cache add postfix-mysql postfix rsyslog && \
    touch /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf \
    /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-email2email.cf && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf smtputf8_enable=no && \
    postconf virtual_transport=lmtp:mda:9001 && \
    postconf smtpd_sasl_path=inet:mda:9000 && \
    postconf smtpd_sasl_type=dovecot && \
    postconf smtpd_sasl_auth_enable=yes && \
    postconf smtpd_tls_security_level=may && \
    postconf smtpd_tls_auth_only=yes && \
    postconf smtpd_tls_cert_file=/media/tls/mailserver.crt && \
    postconf smtpd_tls_key_file=/media/tls/mailserver.key && \
    postconf soft_bounce=no && \
    postconf message_size_limit=50000000 && \
    postconf mailbox_size_limit=0 && \
    postconf recipient_delimiter=- && \
    chgrp postfix /etc/postfix/mysql-*.cf && \
    chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf

COPY config/ /config/
COPY entrypoint.sh /entrypoint.sh

EXPOSE 25
VOLUME /var/spool/postfix

CMD ["/entrypoint.sh"]
