#!/bin/sh

dockerize \
	-wait "tcp://${WEB_HOST}:8080" \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	"${@}"
