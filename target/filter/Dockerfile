ARG RSPAMD_BASE_IMAGE=rspamd/rspamd:3.14@sha256:19aec82d3d4d41fbb2f2bbe4c388581fd860f5382e59d60e2bc3d23cbd54cd41
FROM ${RSPAMD_BASE_IMAGE}

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
