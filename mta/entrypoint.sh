#!/bin/sh

cd /config

for file in $(ls -1)
do
          cat ${file} | sed \
            -e "s/#dbname#/${MYSQL_DBNAME}/g" \
            -e "s/#hosts#/${MYSQL_HOST}/g" \
            -e "s/#password#/${MYSQL_PASSWORD}/g" \
            -e "s/#user#/${MYSQL_USER}/g" > /etc/postfix/${file}
done

rsyslogd
postfix start

tail -f /var/log/maillog
