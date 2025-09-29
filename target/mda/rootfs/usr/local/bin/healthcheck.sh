#!/bin/sh
set -e

if ! doveadm service status; then
	echo "Healthcheck failed: doveadm service status"
	exit 1
fi

if [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_PORT" ]; then
	echo "Healthcheck failed: MYSQL_HOST or MYSQL_PORT not set"
	exit 1
fi
if ! nc -z "$MYSQL_HOST" "$MYSQL_PORT"; then
	echo "Healthcheck failed: cannot connect to $MYSQL_HOST:$MYSQL_PORT"
	exit 1
fi

echo "Healthcheck passed"

exit 0
