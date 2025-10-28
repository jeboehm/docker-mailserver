FROM alpinelinux/unbound:latest@sha256:4b9854f563581dfe59454af5b07999140d78ed5c68e7119ffc9672899d3d10fc

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /

EXPOSE 53/tcp 53/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
