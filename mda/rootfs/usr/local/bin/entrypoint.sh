#!/bin/sh

if [ "${SKIP_INIT}" != "true" ]; then
	if ! [ -r /etc/dovecot/dh.pem.created ]; then
		echo "Using pre-generated Diffie Hellman parameters until the new one is generated."
		/usr/local/bin/dh.sh &
	fi

	/usr/local/bin/init.sh
fi

rm -f /run/dovecot/master.pid

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "file://${SSL_CERT}" \
	-wait "file://${SSL_KEY}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/usr/sbin/dovecot -F
