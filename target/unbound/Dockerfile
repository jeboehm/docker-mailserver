FROM alpinelinux/unbound:latest@sha256:0e9ac80b3e315391ae057b047da2058e49971b2c2b1c32603b4d51ad2338cb71

LABEL maintainer="https://github.com/jeboehm/docker-mailserver"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"
LABEL de.ressourcenkonflikt.docker-mailserver.autoheal="true"

RUN chown -R unbound:unbound /etc/unbound && \
    apk add --no-cache bind-tools
COPY --chown=unbound:unbound rootfs/ /
USER unbound

EXPOSE 5353/tcp 5353/udp
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
