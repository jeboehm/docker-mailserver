FROM alpinelinux/unbound:latest@sha256:ef2c527d31df1de354ade8dc6cfc3c3d60c32edc5b6192faaa99b3dd8f32d767

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN chown -R unbound:unbound /etc/unbound && \
    apk add --no-cache bind-tools
COPY --chown=unbound:unbound rootfs/ /
USER unbound

EXPOSE 5353/TCP 5353/UDP
HEALTHCHECK CMD dig @127.0.0.1 -p 5353 github.com || exit 1
