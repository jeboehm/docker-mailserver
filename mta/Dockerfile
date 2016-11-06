FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8\ 10.0.0.0/8\ 172.16.0.0/12\ 192.168.0.0/16 \
    MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    GREYLISTING_ENABLED=true

RUN apk --no-cache add \
      postfix-mysql \
      postfix \
      postgrey \
      perl-netaddr-ip \
      supervisor && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/rw/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/rw/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/rw/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/rw/mysql-email2email.cf && \
    postconf smtputf8_enable=no && \
    postconf smtpd_milters=inet:spamassassin:9999 && \
    postconf milter_protocol=6 && \
    postconf milter_connect_macros="i j {daemon_name} v {if_name} _" && \
    postconf virtual_transport=lmtp:mda:2003 && \
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
    postconf mynetworks="$MYNETWORKS" && \
    newaliases && \
    mkdir /etc/postfix/rw && \
    mv /etc/postfix/main.cf /etc/postfix/rw/main.cf && \
    ln -sf /etc/postfix/rw/main.cf /etc/postfix/main.cf && \
    rm -rf /var/run /var/lib/postfix && \
    ln -sf /tmp /var/run && \
    ln -sf /tmp /var/lib/postfix

COPY rootfs/ /

EXPOSE 25
VOLUME ["/var/spool/postfix", "/etc/postfix/rw"]

CMD ["/entrypoint.sh"]
