#!/bin/sh

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

for file in /config/postfix/*.cf
do
    if ! [ -e "${file}" ]; then break; fi
    sed \
        -e "s/#dbname#/${MYSQL_DATABASE}/g" \
        -e "s/#hosts#/${MYSQL_HOST}/g" \
        -e "s/#password#/${MYSQL_PASSWORD}/g" \
        -e "s/#user#/${MYSQL_USER}/g" \
        "${file}" > "/etc/postfix/`basename ${file}`"
done

echo "Starting MTA..."


newaliases
/usr/bin/supervisord
