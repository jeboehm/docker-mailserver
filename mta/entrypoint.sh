#!/bin/sh

cd /config

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

for file in $(ls -1)
do
          cat ${file} | sed \
            -e "s/#dbname#/${MYSQL_DATABASE}/g" \
            -e "s/#hosts#/${MYSQL_HOST}/g" \
            -e "s/#password#/${MYSQL_PASSWORD}/g" \
            -e "s/#user#/${MYSQL_USER}/g" > /etc/postfix/${file}
done

echo "Starting MTA..."

touch /var/log/maillog
rsyslogd
postfix start
newaliases

tail -f /var/log/maillog
