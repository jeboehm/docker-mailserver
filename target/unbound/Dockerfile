FROM alpinelinux/unbound:latest@sha256:629d7c2b001523db2eaba7230ace63b38a17fa1aafdfdef29e3befdc71854f81

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /

EXPOSE 53/tcp 53/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
