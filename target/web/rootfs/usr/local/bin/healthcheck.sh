#!/bin/sh
set -e

if ! curl -s http://127.0.0.1:8080/login | grep docker-mailserver; then
	echo "Healthcheck failed: Access to login page failed."
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
