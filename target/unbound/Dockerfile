FROM alpinelinux/unbound:latest@sha256:5fe667869deb8904926ea4efcd520a2194ac1eb373faf2b82e75103dddf2f2ab

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
