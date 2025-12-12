FROM rspamd/rspamd:3.14@sha256:84f418d38d0af2e2ce4a90a38a0a32a8172bf51c8a16960872e2e505cc50bf6a

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    RSPAMD_DNS_SERVERS="round-robin:unbound:5353"

USER root
COPY --chown=root:root rootfs/ /
RUN apt-get update && \
    apt-get install --no-install-recommends -y netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

USER _rspamd

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []
