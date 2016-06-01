#!/bin/sh

tar -xf config.tar

cd /patch
for patch in $(ls -1)
do
	sed -i ${patch} \
		-e "s/#dbname#/${MYSQL_DATABASE}/g" \
		-e "s/#dbhost#/${MYSQL_HOST}/g" \
		-e "s/#dbpassword#/${MYSQL_PASSWORD}/g" \
		-e "s/#dbuser#/${MYSQL_USER}/g"

	patch -p0 < $patch
done

chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext

echo "Starting MDA..."
dovecot -F
