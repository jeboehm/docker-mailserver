#!/bin/sh

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/bin/init.sh
fi

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${MDA_HOST}:143" \
	-wait "tcp://${MTA_HOST}:25" \
	-wait "tcp://${FILTER_HOST}:11334" \
	-wait "tcp://${REDIS_HOST}:${REDIS_PORT}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	/usr/local/bin/init_database.sh

# shellcheck disable=SC3028,SC2155
export APP_SECRET="$(echo $RANDOM | md5sum | head -c 20)"

/usr/bin/supervisord -c /etc/supervisord.conf
