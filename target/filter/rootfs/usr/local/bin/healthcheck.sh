#!/bin/sh
set -e

if ! rspamadm control stat; then
	echo "Healthcheck failed: rspamadm control stat"
	exit 1
fi

if [ -z "$REDIS_HOST" ] || [ -z "$REDIS_PORT" ]; then
	echo "Healthcheck failed: REDIS_HOST or REDIS_PORT not set"
	exit 1
fi
if ! nc -z "$REDIS_HOST" "$REDIS_PORT"; then
	echo "Healthcheck failed: cannot connect to $REDIS_HOST:$REDIS_PORT"
	exit 1
fi

echo "Healthcheck passed"

exit 0
