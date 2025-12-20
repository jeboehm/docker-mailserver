FROM ghcr.io/jeboehm/dockerize:0.9.3@sha256:d4e824aa120670658d7012421d2fdf1b2437be34a6acbb7a4ad92ed52edec8eb AS dockerize
FROM dovecot/dovecot:2.4.2-dev@sha256:647e6934e4981558a603ab32bc1657cb519d3ae24ae1dd7db8ee2782f98de959

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    rm -rf \
        /etc/dovecot/conf.d/mail.conf \
        /etc/dovecot/conf.d/ssl.conf \
        /var/lib/apt/lists/*
USER vmail

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_DATABASE=mailserver \
    FILTER_WEB_ADDRESS=filter:11334 \
    MTA_SMTP_ADDRESS=mta:25 \
    RECIPIENT_DELIMITER=- \
    MAILNAME=mail.example.com \
    MDA_UPSTREAM_PROXY=no \
    POSTMASTER=postmaster@example.com \
    WAITSTART_TIMEOUT=1m

# 2003: LMTP, 2004: AUTH
EXPOSE 2003 2004

COPY --chown=root:root --from=dockerize /bin/dockerize /bin/dockerize
COPY --chown=root:root rootfs/ /

USER root
WORKDIR /etc/dovecot/sieve/global
RUN mv /etc/dovecot/conf.d/10-ssl.conf /tmp/10-ssl.conf && \
    sievec . && \
    mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
USER vmail
WORKDIR /

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
