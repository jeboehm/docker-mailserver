#!/bin/sh

FILTER_VIRUS_ARGS=""
if [ "${FILTER_VIRUS}" = "true" ]; then
	FILTER_VIRUS_ARGS="-wait tcp://${FILTER_VIRUS_HOST}:3310"
fi

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/bin/init.sh
fi

# shellcheck disable=SC2086
dockerize \
	${FILTER_VIRUS_ARGS} \
	-timeout "${WAITSTART_TIMEOUT}" \
	/usr/bin/rspamd -c /etc/rspamd/rspamd.conf -f
