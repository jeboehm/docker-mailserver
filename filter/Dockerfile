FROM rspamd/rspamd:3.13

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    CONTROLLER_PASSWORD= \
    RSPAMD_DNS_SERVERS="round-robin:unbound:53"

COPY --chown=root:root rootfs/ /

HEALTHCHECK CMD rspamadm control stat || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
