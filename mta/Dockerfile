FROM jwilder/dockerize:0.6.1 AS dockerize
FROM alpine:3.18

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8 \
    MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    FILTER_MIME=false \
    RSPAMD_HOST=filter \
    MDA_HOST=mda \
    MTA_HOST=mta \
    RELAYHOST=false \
    SSL_CERT=/media/tls/mailserver.crt \
    SSL_KEY=/media/tls/mailserver.key \
    WAITSTART_TIMEOUT=1m \
    RECIPIENT_DELIMITER=-

RUN apk --no-cache add \
      postfix-mysql \
      postfix && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf smtpd_sender_login_maps=mysql:/etc/postfix/mysql-email-submission.cf && \
    postconf smtpd_recipient_restrictions="permit_mynetworks,reject_unauth_destination,check_recipient_access mysql:/etc/postfix/mysql-recipient-access.cf" && \
    postconf smtputf8_enable=no && \
    postconf smtpd_milters="inet:${RSPAMD_HOST}:11332" && \
    postconf non_smtpd_milters="inet:${RSPAMD_HOST}:11332" && \
    postconf milter_protocol=6 && \
    postconf milter_mail_macros="i {mail_addr} {client_addr} {client_name} {auth_authen}" && \
    postconf milter_default_action=accept && \
    postconf virtual_transport="lmtp:${MDA_HOST}:2003" && \
    postconf smtp_tls_security_level=may && \
    postconf smtpd_tls_security_level=may && \
    postconf smtpd_tls_auth_only=yes && \
    postconf smtpd_tls_cert_file="${SSL_CERT}" && \
    postconf smtpd_tls_key_file="${SSL_KEY}" && \
    postconf smtpd_discard_ehlo_keywords="silent-discard, dsn" && \
    postconf smtpd_sasl_path="inet:${MDA_HOST}:2004" && \
    postconf smtpd_sasl_type=dovecot && \
    postconf smtpd_sasl_auth_enable=yes && \
    postconf soft_bounce=no && \
    postconf message_size_limit=52428800 && \
    postconf mailbox_size_limit=0 && \
    postconf recipient_delimiter="${RECIPIENT_DELIMITER}" && \
    postconf mynetworks="${MYNETWORKS}" && \
    postconf maximal_queue_lifetime=1h && \
    postconf bounce_queue_lifetime=1h && \
    postconf maximal_backoff_time=15m && \
    postconf minimal_backoff_time=5m && \
    postconf queue_run_delay=5m && \
    postconf maillog_file=/dev/stdout && \
    postconf smtpd_tls_mandatory_protocols="TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2" && \
    postconf smtpd_tls_protocols="TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2" && \
    postconf smtp_tls_mandatory_protocols="TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2" && \
    postconf smtp_tls_protocols="TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv3, !SSLv2" && \
    newaliases && \
    echo "submission inet n - n - - smtpd" >> /etc/postfix/master.cf && \
    echo " -o syslog_name=postfix/submission" >> /etc/postfix/master.cf && \
    echo " -o smtpd_tls_security_level=encrypt" >> /etc/postfix/master.cf && \
    echo " -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf && \
    echo " -o smtpd_tls_auth_only=yes" >> /etc/postfix/master.cf && \
    echo " -o smtpd_reject_unlisted_recipient=no" >> /etc/postfix/master.cf && \
    echo " -o smtpd_recipient_restrictions=" >> /etc/postfix/master.cf && \
    echo " -o smtpd_sender_restrictions=reject_sender_login_mismatch,permit_sasl_authenticated,reject" >> /etc/postfix/master.cf && \
    echo " -o smtpd_relay_restrictions=permit_sasl_authenticated,reject" >> /etc/postfix/master.cf && \
    echo " -o milter_macro_daemon_name=ORIGINATING" >> /etc/postfix/master.cf && \
    echo "smtps inet n - n - - smtpd" >> /etc/postfix/master.cf && \
    echo " -o syslog_name=postfix/smtps" >> /etc/postfix/master.cf && \
    echo " -o smtpd_tls_wrappermode=yes" >> /etc/postfix/master.cf && \
    echo " -o smtpd_reject_unlisted_recipient=no" >> /etc/postfix/master.cf && \
    echo " -o smtpd_recipient_restrictions=" >> /etc/postfix/master.cf && \
    echo " -o smtpd_sender_restrictions=reject_sender_login_mismatch,permit_sasl_authenticated,reject" >> /etc/postfix/master.cf && \
    echo " -o smtpd_relay_restrictions=permit_sasl_authenticated,reject" >> /etc/postfix/master.cf && \
    echo " -o milter_macro_daemon_name=ORIGINATING" >> /etc/postfix/master.cf

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 25
VOLUME ["/var/spool/postfix"]

HEALTHCHECK CMD postfix status || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
