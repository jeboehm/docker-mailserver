FROM alpinelinux/unbound:latest@sha256:0dc89579b083027feb21d476b60145f0a73c08d2f3b13e64f6d6c183ad043637

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /

EXPOSE 53/tcp 53/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
