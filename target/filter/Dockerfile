FROM rspamd/rspamd:4.2@sha256:01131b1af11f71680f48a5eaa2d8409bef25158979d02d1bcc375ea26e4ffb28

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
