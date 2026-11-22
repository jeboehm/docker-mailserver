FROM rspamd/rspamd:4.3@sha256:48abfb002120face66eab1f43bd1a22d98cbe058749a412fb3e9403449a022c7

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
