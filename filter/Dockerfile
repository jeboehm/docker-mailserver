FROM rspamd/rspamd:3.13

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    CONTROLLER_PASSWORD= \
    RSPAMD_DNS_SERVERS="round-robin:unbound:53"

COPY rootfs/ /

HEALTHCHECK CMD rspamadm control stat || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
