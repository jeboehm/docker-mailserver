FROM alpine:3.6
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8\ 10.0.0.0/8\ 172.16.0.0/12\ 192.168.0.0/16 \
    MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    GREYLISTING_ENABLED=true \
    GREYLISTING_DELAY=50 \
    DISCARD_DSN=true \
    FILTER_MIME=false \
    DOCKERIZE_VERSION=v0.5.0 \
    SPAMASSASSIN_HOST=spamassassin \
    MDA_HOST=mda \
    MTA_HOST=mta \
    SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key

RUN apk --no-cache add \
      openssl \
      postfix-mysql \
      postfix \
      postgrey \
      perl-netaddr-ip \
      supervisor && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf smtputf8_enable=no && \
    postconf smtpd_milters=inet:${SPAMASSASSIN_HOST}:9999 && \
    postconf milter_protocol=6 && \
    postconf milter_connect_macros="i j {daemon_name} v {if_name} _" && \
    postconf virtual_transport=lmtp:${MDA_HOST}:2003 && \
    postconf smtpd_sasl_path=inet:${MDA_HOST}:9000 && \
    postconf smtpd_sasl_type=dovecot && \
    postconf smtpd_sasl_auth_enable=yes && \
    postconf smtpd_tls_security_level=may && \
    postconf smtpd_tls_auth_only=yes && \
    postconf smtpd_tls_cert_file=${SSL_CERT} && \
    postconf smtpd_tls_key_file=${SSL_KEY} && \
    postconf soft_bounce=no && \
    postconf message_size_limit=50000000 && \
    postconf mailbox_size_limit=0 && \
    postconf recipient_delimiter=- && \
    postconf mynetworks="$MYNETWORKS" && \
    newaliases && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY rootfs/ /

EXPOSE 25
VOLUME ["/var/spool/postfix"]

HEALTHCHECK CMD postfix status || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
