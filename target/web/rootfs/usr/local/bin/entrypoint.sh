#!/bin/sh
set -e

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/lib/init.sh
fi

# shellcheck disable=SC3028,SC2155
export APP_SECRET="$(echo $RANDOM | md5sum | head -c 20)"

exec frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile
