FROM alpinelinux/unbound:latest@sha256:e8665c4231b336f57c8ea01c4a795f36e1ebf6a440f69d9c1e7f4395b0d9b52c

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN chown -R unbound:unbound /etc/unbound && \
    apk add --no-cache bind-tools
COPY --chown=unbound:unbound rootfs/ /
USER unbound

EXPOSE 5353/tcp 5353/udp
HEALTHCHECK CMD dig @127.0.0.1 -p 5353 github.com || exit 1
