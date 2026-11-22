FROM alpinelinux/unbound:latest@sha256:b6d8bfac6a327304175454c32e689ee66e699ec32caa44376202e13eac6b06c8

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN apk add --no-cache bind-tools
COPY rootfs/ /
USER 100:101

EXPOSE 5353/tcp 5353/udp
HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/entrypoint.sh"]
CMD []
