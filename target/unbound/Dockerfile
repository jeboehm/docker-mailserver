FROM alpinelinux/unbound:latest@sha256:cd8dcbcaa7b6f223fe154be07f17c13006149be7f56d50c5664f46181e8d5e1b

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /
USER unbound

EXPOSE 5353/tcp 5353/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
