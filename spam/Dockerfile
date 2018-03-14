FROM jwilder/dockerize:0.6.0 AS dockerize

FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"

RUN apk --no-cache add rspamd rspamd-proxy && \
    mkdir /run/rspamd && \
    chown -R rspamd /run/rspamd /var/lib/rspamd

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin
COPY rootfs/ /

EXPOSE 11332 11334
USER rspamd

VOLUME ["/var/lib/rspamd"]
CMD ["/usr/sbin/rspamd", "-c", "/etc/rspamd/rspamd.conf", "-f"]
