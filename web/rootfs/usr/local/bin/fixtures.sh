#!/bin/sh

# shellcheck disable=SC2086
dockerize \
	-wait "tcp://${WEB_HOST}:80" \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	${@}
