FROM alpinelinux/unbound:latest@sha256:e3d4dc5ce1ae05966e65622a74ad2049190427a8fc239d8762af00c91c2808e9

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN chown -R unbound:unbound /etc/unbound && \
    apk add --no-cache bind-tools
COPY --chown=unbound:unbound rootfs/ /
USER unbound

EXPOSE 5353/TCP 5353/UDP
HEALTHCHECK CMD dig @127.0.0.1 -p 5353 github.com || exit 1
