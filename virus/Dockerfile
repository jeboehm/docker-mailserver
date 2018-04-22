FROM alpine:3.7
LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

ENV FILTER_VIRUS=true

RUN apk --no-cache add \
      clamav-daemon \
      clamav-libunrar && \
    rm -rf /var/log/clamav

COPY rootfs/ /

EXPOSE 3310
USER clamav

RUN /usr/bin/freshclam -l /dev/null

VOLUME ["/var/lib/clamav"]
CMD ["/usr/local/bin/entrypoint.sh"]
