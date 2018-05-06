FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8\ 10.0.0.0/8\ 172.16.0.0/12\ 192.168.0.0/16 \
    MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    FILTER_MIME=false \
    RSPAMD_HOST=filter \
    MDA_HOST=mda \
    MTA_HOST=mta \
    SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key \
    WAITSTART_TIMEOUT=1m

RUN apk --no-cache add \
      postfix-mysql \
      postfix \
      supervisor && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf smtputf8_enable=no && \
    postconf smtpd_milters=inet:${RSPAMD_HOST}:11332 && \
    postconf non_smtpd_milters=inet:${RSPAMD_HOST}:11332 && \
    postconf milter_protocol=6 && \
    postconf milter_mail_macros="i {mail_addr} {client_addr} {client_name} {auth_authen}" && \
    postconf milter_default_action=accept && \
    postconf virtual_transport=lmtp:${MDA_HOST}:2003 && \
    postconf smtpd_sasl_path=inet:${MDA_HOST}:9000 && \
    postconf smtpd_sasl_type=dovecot && \
    postconf smtpd_sasl_auth_enable=yes && \
    postconf smtpd_tls_security_level=may && \
    postconf smtpd_tls_auth_only=yes && \
    postconf smtpd_tls_cert_file=${SSL_CERT} && \
    postconf smtpd_tls_key_file=${SSL_KEY} && \
    postconf smtpd_discard_ehlo_keywords="silent-discard, dsn" && \
    postconf soft_bounce=no && \
    postconf message_size_limit=50000000 && \
    postconf mailbox_size_limit=0 && \
    postconf recipient_delimiter=- && \
    postconf mynetworks="$MYNETWORKS" && \
    newaliases

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 25
VOLUME ["/var/spool/postfix"]

HEALTHCHECK CMD postfix status || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
