#!/bin/sh
set -e

if ! doveadm service status; then
	echo "Healthcheck failed: doveadm service status"
	exit 1
fi

if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ]; then
	echo "Healthcheck failed: DB_HOST or DB_PORT not set"
	exit 1
fi
if ! nc -z "$DB_HOST" "$DB_PORT"; then
	echo "Healthcheck failed: cannot connect to $DB_HOST:$DB_PORT"
	exit 1
fi

echo "Healthcheck passed"

exit 0
