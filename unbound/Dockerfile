FROM alpinelinux/unbound:latest

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

COPY rootfs/ /

EXPOSE 53/TCP 53/UDP

HEALTHCHECK CMD nslookup github.com 127.0.0.1 || exit 1
