#!/bin/sh
set -e

/usr/local/lib/init.sh

exec dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${MDA_LMTP_ADDRESS}" \
	-wait "tcp://${FILTER_MILTER_ADDRESS}" \
	-wait "file://${SSL_CERT}" \
	-wait "file://${SSL_KEY}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/usr/sbin/postfix start-fg
