ARG ALPINE_VER=3.9

FROM alpine:${ALPINE_VER}

LABEL maintainer="jeff@ressourcenkonflikt.de"
LABEL vendor="https://github.com/jeboehm/docker-mailserver"

# hadolint ignore=DL3003
RUN apk --no-cache add \
        bash \
        bind-tools \
        clamav-scanner \
        gnupg \
        ncurses \
        rsync \
        wget && \
    wget -q -O /tmp/master.tar.gz https://github.com/extremeshok/clamav-unofficial-sigs/archive/master.tar.gz && \
    cd /tmp && \
        tar -xvf master.tar.gz && \
    cd clamav-unofficial-sigs-master && \
        cp clamav-unofficial-sigs.sh /usr/local/bin/ && \
        chmod +x /usr/local/bin/clamav-unofficial-sigs.sh && \
        cp -r config /etc/clamav-unofficial-sigs && \
        mkdir /var/lib/clamav-unofficial-sigs && \
        chown clamav /var/lib/clamav-unofficial-sigs && \
        cp /etc/clamav-unofficial-sigs/os.ubuntu.conf /etc/clamav-unofficial-sigs/os.conf && \
        echo "user_configuration_complete=\"yes\"" >> /etc/clamav-unofficial-sigs/user.conf && \
        echo "logging_enabled=\"no\"" >> /etc/clamav-unofficial-sigs/user.conf && \
        echo "enable_random=\"no\"" >> /etc/clamav-unofficial-sigs/user.conf && \
    rm -rf /tmp/* /var/log/*

USER clamav

CMD ["/usr/local/bin/clamav-unofficial-sigs.sh"]
