FROM alpinelinux/unbound:latest@sha256:6af121cd991e6e79d0d9a9146197a23e23adb502867435975e83d55ab5076d10

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /

EXPOSE 53/tcp 53/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
