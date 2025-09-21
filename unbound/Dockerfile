FROM alpinelinux/unbound:latest

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

COPY --chown=root:root rootfs/ /

EXPOSE 53/TCP 53/UDP

HEALTHCHECK CMD nslookup github.com 127.0.0.1 || exit 1
