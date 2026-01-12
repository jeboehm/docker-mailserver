FROM ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb AS dockerize
FROM alpine:3.23@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8 \
    MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_DATABASE=mailserver \
    MYSQL_TLS_VERIFY_CERT=no \
    MDA_LMTP_ADDRESS=mda:2003 \
    MDA_AUTH_ADDRESS=mda:2004 \
    FILTER_MILTER_ADDRESS=filter:11332 \
    FILTER_MIME=false \
    RELAYHOST=false \
    RELAY_PASSWD_FILE=false \
    WAITSTART_TIMEOUT=1m \
    RECIPIENT_DELIMITER=-

RUN apk --no-cache add \
      postfix-mysql \
      postfix && \
    postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf && \
    postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf && \
    postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf && \
    postconf smtpd_sender_login_maps=mysql:/etc/postfix/mysql-email-submission.cf && \
    postconf smtpd_recipient_restrictions="reject_unauth_destination,check_recipient_access mysql:/etc/postfix/mysql-recipient-access.cf" && \
    postconf smtpd_milters="inet:${FILTER_MILTER_ADDRESS}" && \
    postconf non_smtpd_milters="inet:${FILTER_MILTER_ADDRESS}" && \
    postconf milter_protocol=6 && \
    postconf milter_mail_macros="i {mail_addr} {client_addr} {client_name} {auth_authen}" && \
    postconf milter_default_action=accept && \
    postconf virtual_transport="lmtp:${MDA_LMTP_ADDRESS}" && \
    postconf smtp_tls_security_level=may && \
    postconf smtpd_tls_security_level=may && \
    postconf smtpd_tls_auth_only=yes && \
    postconf smtpd_tls_cert_file="/etc/postfix/tls/tls.crt" && \
    postconf smtpd_tls_key_file="/etc/postfix/tls/tls.key" && \
    postconf smtpd_discard_ehlo_keywords="silent-discard, dsn" && \
    postconf smtpd_sasl_path="inet:${MDA_AUTH_ADDRESS}" && \
    postconf smtpd_sasl_type=dovecot && \
    postconf smtpd_sasl_auth_enable=no && \
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
    postconf smtpd_client_connection_rate_limit=20 && \
    postconf smtpd_error_sleep_time=10s && \
    postconf smtpd_soft_error_limit=3 && \
    postconf smtpd_hard_error_limit=5 && \
    newaliases
COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

EXPOSE 25 587
VOLUME ["/var/spool/postfix"]

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []
