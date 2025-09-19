#!/bin/sh

dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${WEB_HTTP_ADDRESS}" \
	-wait "tcp://${IMAP_ADDRESS}" \
	-wait "tcp://${SMTP_SUBMISSION_ADDRESS}" \
	-wait "tcp://${FILTER_WEB_ADDRESS}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	bats /usr/share/tests/*.bats
