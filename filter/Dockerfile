FROM ghcr.io/jeboehm/dockerize:0.9.3 AS dockerize
FROM alpine:3.21

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV FILTER_VIRUS=false \
    FILTER_VIRUS_HOST=virus.local \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    WAITSTART_TIMEOUT=1m \
    CONTROLLER_PASSWORD=changeme

RUN apk --no-cache add \
      openssl \
      rspamd \
      rspamd-client \
      rspamd-controller \
      rspamd-proxy && \
    mkdir /run/rspamd && \
    touch \
      /etc/rspamd/local.d/antivirus.conf \
      /etc/rspamd/override.d/redis.conf \
      /etc/rspamd/local.d/worker-controller.inc && \
    chown -R rspamd \
      /run/rspamd \
      /var/lib/rspamd \
      /etc/rspamd/local.d/antivirus.conf \
      /etc/rspamd/override.d/redis.conf \
      /etc/rspamd/local.d/worker-controller.inc && \
    apk --no-cache del \
      openssl

COPY --from=dockerize /bin/dockerize /usr/local/bin/dockerize
COPY rootfs/ /

EXPOSE 11332 11334
USER rspamd

VOLUME ["/var/lib/rspamd"]

HEALTHCHECK CMD wget -O- -T 10 http://127.0.0.1:11334/stat
CMD ["/usr/local/bin/entrypoint.sh"]
