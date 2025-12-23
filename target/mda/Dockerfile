FROM dovecot/dovecot:2.4.1-dev@sha256:99f45812578122e62663503f55bd32919e96c7b048349539a8511c3e71c00e3e

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_DATABASE=mailserver \
    FILTER_WEB_ADDRESS=filter:11334 \
    MAILNAME=mail.example.com \
    MDA_UPSTREAM_PROXY=no \
    MTA_SMTP_ADDRESS=mta:25 \
    POSTMASTER=postmaster@example.com \
    RECIPIENT_DELIMITER=-

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    rm -rf \
        /etc/dovecot/conf.d/auth.conf \
        /etc/dovecot/conf.d/mail.conf \
        /etc/dovecot/conf.d/ssl.conf \
        /srv/mail \
        /var/lib/apt/lists/*

COPY --chown=root:root rootfs/ /

WORKDIR /etc/dovecot/sieve/global
RUN mv /etc/dovecot/conf.d/10-ssl.conf /tmp/10-ssl.conf && \
    sievec . && \
    mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf

USER vmail
WORKDIR /

# 2003: LMTP, 2004: AUTH
EXPOSE 2003 2004

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
