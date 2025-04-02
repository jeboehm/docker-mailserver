#!/bin/sh

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/bin/init.sh
fi

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${MDA_HOST}:2003" \
	-wait "tcp://${FILTER_HOST}:11332" \
	-wait "file://${SSL_CERT}" \
	-wait "file://${SSL_KEY}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/usr/sbin/postfix start-fg
