#!/bin/sh

tar -xf config.tar
cd /patch

for patch in $(ls -1)
do
	sed -i ${patch} \
		-e "s/#dbname#/${MYSQL_DATABASE}/g" \
		-e "s/#dbhost#/${MYSQL_HOST}/g" \
		-e "s/#dbpassword#/${MYSQL_PASSWORD}/g" \
		-e "s/#dbuser#/${MYSQL_USER}/g" \
		-e "s/#postmaster#/${POSTMASTER}/g" \
		-e "s/#mailname#/${MAILNAME}/g"

	patch -p0 < $patch
done

chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext

if ! [ -r /media/tls/mailserver.crt ]
then
	/usr/local/bin/create_tls.sh
fi

echo "Starting MDA..."

touch /var/log/maillog
rsyslogd
dovecot

tail -f /var/log/maillog
