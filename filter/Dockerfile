FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV FILTER_VIRUS=false \
    FILTER_VIRUS_HOST=virus.local \
    WAITSTART_TIMEOUT=1m

RUN apk --no-cache add \
      rspamd \
      rspamd-controller \
      rspamd-proxy && \
    mkdir /run/rspamd && \
    touch /etc/rspamd/override.d/antivirus.conf && \
    chown -R rspamd \
      /run/rspamd \
      /var/lib/rspamd \
      /etc/rspamd/override.d/antivirus.conf

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 11332 11334
USER rspamd

VOLUME ["/var/lib/rspamd"]
CMD ["/usr/local/bin/entrypoint.sh"]
