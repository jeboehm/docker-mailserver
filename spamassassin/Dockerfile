FROM debian:jessie
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    supervisor \
    spamassassin \
    pyzor \
    razor \
    spamass-milter && \
    rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

EXPOSE 9999

VOLUME /var/lib/spamassassin

CMD ["/usr/bin/supervisord"]
