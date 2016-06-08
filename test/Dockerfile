FROM alpine:3.4
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST=db
    MYSQL_USER=root
    MYSQL_PASSWORD=changeme
    MYSQL_DATABASE=mailserver
    SWAKSURL=http://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks

RUN apk --no-cache add curl mariadb-client openssl perl perl-net-ssleay postfix \
    && curl -SLk ${SWAKSURL} -o swaks \
    && chmod +x swaks \
    && mv swaks /usr/bin

COPY run-tests.sh tests /opt/test/
