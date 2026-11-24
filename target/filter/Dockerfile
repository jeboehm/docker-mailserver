FROM rspamd/rspamd:4.3@sha256:bcac3a454fc0601760509998af61dda9bd05ad232886b90e1ec630f05048054e

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    RSPAMD_DNS_SERVERS="round-robin:unbound:5353"

USER 0:0

RUN apt-get update && \
    apt-get install --no-install-recommends -y netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=root:root rootfs/ /

USER 11333:11333

HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD []
