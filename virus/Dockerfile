FROM alpine:3.22@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

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

HEALTHCHECK CMD echo PING | nc 127.0.0.1 3310 | grep PONG
CMD ["/usr/local/bin/entrypoint.sh"]
