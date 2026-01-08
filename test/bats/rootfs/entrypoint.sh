#!/bin/sh

if [ "${IS_KUBERNETES}" -eq "1" ]; then
	/usr/local/bin/kubectl.sh
fi

exec dockerize \
	-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
	-wait "tcp://${FILTER_WEB_ADDRESS}" \
	-wait "tcp://${MDA_IMAP_ADDRESS}" \
	-wait "tcp://${MTA_SMTP_SUBMISSION_ADDRESS}" \
	-wait "tcp://${WEB_HTTP_ADDRESS}" \
	-timeout "${WAITSTART_TIMEOUT}" \
	"${@}"
