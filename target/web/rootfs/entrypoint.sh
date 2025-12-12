#!/bin/sh
set -e

# shellcheck disable=SC3028,SC2155
export APP_SECRET="$(echo $RANDOM | md5sum | head -c 20)"

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/lib/init.sh
fi

exec frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile
