FROM rspamd/rspamd:4.2@sha256:3f2eba25b14e972f67d5d022b43f00a2f9efaaeab047d58fc62531ecd8bdd50a

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
