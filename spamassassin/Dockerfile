FROM alpine:3.6
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV SPAMASS_USER=spamass \
    SPAMASS_GROUP=spamass \
    SPAMASS_CONF=/var/lib/spamassassin \
    SA_HOME=/var/lib/spamassassin/.spamassassin \
    SA_PORT=1783

RUN apk --no-cache add \
      libgcc \
      libmilter-dev \
      libstdc++ \
      openssl \
      perl-mail-spf \
      python3 \
      razor \
      spamassassin \
      spamassassin-client \
      supervisor \
      wget && \
    apk --no-cache add --virtual .fetch-deps \
          autoconf \
          automake \
          build-base && \
    pip3 install \
      pyzor && \
    wget https://github.com/andybalholm/spamass-milter/archive/master.tar.gz && \
    tar -xvf master.tar.gz && \
      cd spamass-milter-master && \
      ./autogen.sh && \
      make && \
      make install && \
      cd / && \
    rm -rf spamass-milter-master master.tar.gz && \
    apk del .fetch-deps && \
    addgroup -S ${SPAMASS_GROUP} && \
    adduser -D ${SPAMASS_USER} -G ${SPAMASS_GROUP} && \
    chgrp ${SPAMASS_GROUP} ${SPAMASS_CONF} && \
    chmod 775 ${SPAMASS_CONF}

USER ${SPAMASS_USER}
VOLUME ["${SPAMASS_CONF}"]

COPY rootfs/ /

EXPOSE 9999

HEALTHCHECK CMD spamc -K -p ${SA_PORT} || exit 1
CMD ["/usr/bin/supervisord"]
