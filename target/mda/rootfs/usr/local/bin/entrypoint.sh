#!/bin/sh

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "file:///etc/dovecot/tls/tls.crt" \
	-wait "file:///etc/dovecot/tls/tls.key" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/dovecot/sbin/dovecot -F
