#!/bin/sh
set -e

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

exec /usr/local/bin/entrypoint.sh
