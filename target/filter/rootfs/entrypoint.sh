#!/bin/sh
set -e

if [ "${CONTROLLER_PASSWORD}" = "" ]; then
	# q1 is disabled in rspamd.
	RSPAMD_CONTROLLER_PASSWORD_ENC="q1"
else
	RSPAMD_CONTROLLER_PASSWORD_ENC="$(rspamadm pw -e -p "${CONTROLLER_PASSWORD}")"
fi

export RSPAMD_CONTROLLER_PASSWORD_ENC

export RSPAMD_REDIS_PASSWORD="${REDIS_PASSWORD}"
export RSPAMD_REDIS_HOST="${REDIS_HOST}"
export RSPAMD_REDIS_PORT="${REDIS_PORT}"

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

exec /usr/bin/rspamd -f
