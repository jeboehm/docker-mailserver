FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV FILTER_VIRUS=false \
    FILTER_VIRUS_HOST=virus.local \
    WAITSTART_TIMEOUT=1m

RUN apk --no-cache add \
      openssl \
      rspamd \
      rspamd-controller \
      rspamd-proxy && \
    mkdir /run/rspamd && \
    touch /etc/rspamd/local.d/antivirus.conf && \
    chown -R rspamd \
      /run/rspamd \
      /var/lib/rspamd \
      /etc/rspamd/local.d/antivirus.conf && \
    wget -O /usr/share/rspamd/bayes.spam.sqlite https://rspamd.com/rspamd_statistics/bayes.spam.sqlite && \
    wget -O /usr/share/rspamd/bayes.ham.sqlite https://rspamd.com/rspamd_statistics/bayes.ham.sqlite && \
    apk --no-cache del \
      openssl

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 11332 11334
USER rspamd

VOLUME ["/var/lib/rspamd"]
CMD ["/usr/local/bin/entrypoint.sh"]
