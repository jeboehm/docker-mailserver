FROM rspamd/rspamd:3.13@sha256:98c226bc6c5a60c8437042b33b96926f37b54dca4a85181471312b0c62df4137

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    CONTROLLER_PASSWORD= \
    RSPAMD_DNS_SERVERS="round-robin:unbound:5353"

COPY --chown=root:root rootfs/ /

HEALTHCHECK CMD rspamadm control stat || exit 1
CMD ["/usr/local/bin/entrypoint.sh"]
