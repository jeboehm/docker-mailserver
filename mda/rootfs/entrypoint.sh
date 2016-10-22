#!/bin/sh

for file in /etc/dovecot/rw/*
do
    if ! [ -e "${file}" ]; then break; fi
    sed -i "${file}" \
        -e "s/#dbname#/${MYSQL_DATABASE}/g" \
        -e "s/#dbhost#/${MYSQL_HOST}/g" \
        -e "s/#dbpassword#/${MYSQL_PASSWORD}/g" \
        -e "s/#dbuser#/${MYSQL_USER}/g" \
        -e "s/#postmaster#/${POSTMASTER}/g" \
        -e "s/#mailname#/${MAILNAME}/g"
done

chown root:root /etc/dovecot/rw/dovecot-sql.conf.ext
chmod go= /etc/dovecot/rw/dovecot-sql.conf.ext

if ! [ -r /media/tls/mailserver.crt ]
then
    /usr/local/bin/create_tls.sh
fi

echo "Starting MDA..."

dovecot -F
