FROM alpinelinux/unbound:latest@sha256:3d1a2772cd413554fec9b8cd399c6878d80fc7789330c7b69ae1b2c09db70030

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
