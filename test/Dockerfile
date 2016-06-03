FROM alpine:edge
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST db
ENV MYSQL_USER root
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DATABASE mailserver

RUN apk --no-cache add curl swaks mariadb-client openssl
