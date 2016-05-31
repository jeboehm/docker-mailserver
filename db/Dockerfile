FROM k0st/alpine-mariadb
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_DATABASE mailserver
ENV MYSQL_USER mailserver
ENV MYSQL_PASSWORD changeme
ENV MYSQL_ROOT_PASSWORD changeme

ADD init.sql /scripts/pre-exec.d/init.sql
ADD init.sh /scripts/pre-exec.d/init.sh
