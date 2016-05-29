FROM alpine:3.3
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV MYSQL_HOST db
ENV MYSQL_USER root
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DBNAME mailserver

RUN apk --no-cache add dovecot dovecot-mysql
RUN adduser -h /var/vmail -u 5000 -D vmail

ADD patch/ /patch
ADD entrypoint.sh /entrypoint.sh
ADD install.sh /install.sh

#EXPOSE 25
VOLUME /var/vmail

CMD ["/install.sh"]
CMD ["dovecot", "-F"]
