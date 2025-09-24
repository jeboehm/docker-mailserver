#!/bin/sh
set -e

if [ -r /run/dovecot/master.pid ]; then
	rm /run/dovecot/master.pid
fi

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "file:///etc/dovecot/tls/tls.crt" \
	-wait "file:///etc/dovecot/tls/tls.key" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/dovecot/sbin/dovecot -F
