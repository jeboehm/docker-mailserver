FROM alpinelinux/unbound:latest@sha256:ca8f3e0bb53e60f14368f4dcf72ffe9c0153bc17c75ba5df319c518ebaec8feb

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /

EXPOSE 53/tcp 53/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
