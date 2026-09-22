FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS base

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV DB_DRIVER=mysql \
    DB_HOST=db \
    DB_PORT=3306 \
    DB_USER=root \
    DB_NAME=mailserver \
    DB_TLS_VERIFY_CERT=no \
    FILTER_WEB_ADDRESS=filter:11334 \
    MAILNAME=mail.example.com \
    MDA_UPSTREAM_PROXY=no \
    MTA_SMTP_ADDRESS=mta:25 \
    POSTMASTER=postmaster@example.com \
    RECIPIENT_DELIMITER=-

RUN apk add --no-cache \
      curl \
      dovecot \
      dovecot-fts-flatcurve \
      dovecot-lmtpd \
      dovecot-mysql \
      dovecot-pgsql \
      dovecot-pigeonhole-plugin \
      dovecot-pop3d && \
    adduser -DH vmail && \
    mkdir -p /srv/vmail && \
    chown -R vmail:vmail /srv/vmail

COPY --chown=root:root rootfs/ /

WORKDIR /etc/dovecot/sieve/global
RUN mv /etc/dovecot/conf.d/10-ssl.conf /tmp/10-ssl.conf && \
    sievec . && \
    mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf

USER vmail
WORKDIR /

# LMTP
EXPOSE 2003
# AUTH
EXPOSE 2004
# IMAP
EXPOSE 31143
EXPOSE 31993
# POP3
EXPOSE 31110
EXPOSE 31995
# MANAGESIEVE
EXPOSE 4190
# DOVEADM
EXPOSE 8080

VOLUME ["/srv/vmail"]
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
