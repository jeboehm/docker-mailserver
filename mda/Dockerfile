FROM ghcr.io/jeboehm/dockerize:0.9.3 AS dockerize
FROM dovecot/dovecot:2.4.1-dev

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    rm -rf /var/lib/apt/lists/*
USER vmail

ENV MYSQL_HOST=db \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    FILTER_WEB_ADDRESS=filter:11334 \
    CONTROLLER_PASSWORD= \
    RECIPIENT_DELIMITER=- \
    MAILNAME=mail.example.com \
    POSTMASTER=postmaster@example.com \
    SMTP_ADDRESS=mta:25

# 2003: LMTP, 2004: AUTH
EXPOSE 2003 2004

COPY --chown=root:root --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY --chown=root:root rootfs/ /

USER root
RUN mv /etc/dovecot/conf.d/10-ssl.conf /tmp/10-ssl.conf && \
    cd /etc/dovecot/sieve/global && \
    sievec . && \
    mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
USER vmail

HEALTHCHECK CMD doveadm service status || exit 1

CMD ["/usr/local/bin/entrypoint.sh"]
