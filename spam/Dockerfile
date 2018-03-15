FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

RUN apk --no-cache add \
      rspamd \
      rspamd-proxy && \
    mkdir /run/rspamd && \
    chown -R rspamd /run/rspamd /var/lib/rspamd

COPY rootfs/ /

EXPOSE 11332
USER rspamd

VOLUME ["/var/lib/rspamd"]
CMD ["/usr/sbin/rspamd", "-c", "/etc/rspamd/rspamd.conf", "-f"]
