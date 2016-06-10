FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db \
    MYSQL_USER=root \
    MYSQL_PASSWORD=changeme \
    MYSQL_DATABASE=mailserver \
    SWAKSURL=http://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks \
    BATSVERSION=v0.4.0

RUN apk --no-cache add curl mariadb-client openssl perl perl-net-ssleay postfix bash \
    && curl -SLk ${SWAKSURL} -o swaks \
    && chmod +x swaks \
    && mv swaks /usr/bin \
    && wget -q -O- https://github.com/sstephenson/bats/archive/$BATSVERSION.tar.gz | tar -xzv \
    && ./bats-0.4.0/install.sh /usr/local \
    && rm -rf /bats-0.4.0

COPY tests/ /opt/tests/
