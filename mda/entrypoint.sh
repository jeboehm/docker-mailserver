#!/bin/sh

tar -xf config.tar
cd /patch || exit

for patch in *.patch
do
        if ! [ -e "${patch}" ]; then break; fi
	sed "${patch}" \
		-e "s/#dbname#/${MYSQL_DATABASE}/g" \
		-e "s/#dbhost#/${MYSQL_HOST}/g" \
		-e "s/#dbpassword#/${MYSQL_PASSWORD}/g" \
		-e "s/#dbuser#/${MYSQL_USER}/g" \
		-e "s/#postmaster#/${POSTMASTER}/g" \
		-e "s/#mailname#/${MAILNAME}/g" \
                > "/tmp/${patch}"

	patch -p0 < "/tmp/${patch}"
        rm "/tmp/${patch}"
done

chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext

if ! [ -r /media/tls/mailserver.crt ]
then
	/usr/local/bin/create_tls.sh
fi

echo "Starting MDA..."

dovecot -F
