#!/bin/sh

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${WEB_HTTP_ADDRESS}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	"${@}"
