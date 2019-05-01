ARG DOCKERIZE_VER=0.6.0
ARG ALPINE_VER=3.9

FROM jwilder/dockerize:${DOCKERIZE_VER} AS dockerize
FROM alpine:${ALPINE_VER}

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

ENV FILTER_VIRUS=false \
    FILTER_VIRUS_HOST=virus.local \
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
      /etc/rspamd/local.d/worker-controller.inc && \
    chown -R rspamd \
      /run/rspamd \
      /var/lib/rspamd \
      /etc/rspamd/local.d/antivirus.conf \
      /etc/rspamd/local.d/worker-controller.inc && \
    wget -O /usr/share/rspamd/bayes.spam.sqlite https://rspamd.com/rspamd_statistics/bayes.spam.sqlite && \
    wget -O /usr/share/rspamd/bayes.ham.sqlite https://rspamd.com/rspamd_statistics/bayes.ham.sqlite && \
    apk --no-cache del \
      openssl

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 11332 11334
USER rspamd

VOLUME ["/var/lib/rspamd"]

HEALTHCHECK CMD wget -O- -T 10 http://127.0.0.1:11334/stat
CMD ["/usr/local/bin/entrypoint.sh"]
