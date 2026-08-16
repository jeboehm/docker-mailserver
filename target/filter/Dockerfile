FROM rspamd/rspamd:4.1@sha256:d9ab337af1ce05b63f262012e38effcbe97513a2a0628c4e5ad0346c76d81735

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    RSPAMD_DNS_SERVERS="round-robin:unbound:5353"

USER root

RUN apt-get update && \
    apt-get install --no-install-recommends -y netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=root:root rootfs/ /

USER _rspamd

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []
