#!/bin/sh
set -e

if [ -r /run/dovecot/master.pid ]; then
	rm /run/dovecot/master.pid
fi

if [ -n "${MDA_UPSTREAM_PROXY}" ]; then
	if [ "${MDA_UPSTREAM_PROXY}" = "true" ]; then
		export MDA_UPSTREAM_PROXY="yes"
	elif [ "${MDA_UPSTREAM_PROXY}" = "false" ]; then
		export MDA_UPSTREAM_PROXY="no"
	else
		export MDA_UPSTREAM_PROXY
	fi
fi

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "file:///etc/dovecot/tls/tls.crt" \
	-wait "file:///etc/dovecot/tls/tls.key" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/dovecot/sbin/dovecot -F
