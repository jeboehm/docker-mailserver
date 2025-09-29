#!/bin/sh
set -e

# 1. test connection to 0.0.0.0:25
if ! nc -z 0.0.0.0 25; then
	echo "Healthcheck failed: cannot connect to 0.0.0.0:25"
	exit 1
fi

# 2. test connection to $MYSQL_HOST:$MYSQL_PORT
if [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_PORT" ]; then
	echo "Healthcheck failed: MYSQL_HOST or MYSQL_PORT not set"
	exit 1
fi
if ! nc -z "$MYSQL_HOST" "$MYSQL_PORT"; then
	echo "Healthcheck failed: cannot connect to $MYSQL_HOST:$MYSQL_PORT"
	exit 1
fi

# 4. test connection to $MDA_AUTH_ADDRESS
if [ -z "$MDA_AUTH_ADDRESS" ]; then
	echo "Healthcheck failed: MDA_AUTH_ADDRESS not set"
	exit 1
fi
MDA_AUTH_HOST=$(echo "$MDA_AUTH_ADDRESS" | cut -d: -f1)
MDA_AUTH_PORT=$(echo "$MDA_AUTH_ADDRESS" | cut -d: -f2)
if ! nc -z "$MDA_AUTH_HOST" "$MDA_AUTH_PORT"; then
	echo "Healthcheck failed: cannot connect to $MDA_AUTH_ADDRESS"
	exit 1
fi

# 5. test connection to $MDA_LMTP_ADDRESS
if [ -z "$MDA_LMTP_ADDRESS" ]; then
	echo "Healthcheck failed: MDA_LMTP_ADDRESS not set"
	exit 1
fi
MDA_LMTP_HOST=$(echo "$MDA_LMTP_ADDRESS" | cut -d: -f1)
MDA_LMTP_PORT=$(echo "$MDA_LMTP_ADDRESS" | cut -d: -f2)
if ! nc -z "$MDA_LMTP_HOST" "$MDA_LMTP_PORT"; then
	echo "Healthcheck failed: cannot connect to $MDA_LMTP_ADDRESS"
	exit 1
fi

# 6. test connection to $FILTER_MILTER_ADDRESS
if [ -z "$FILTER_MILTER_ADDRESS" ]; then
	echo "Healthcheck failed: FILTER_MILTER_ADDRESS not set"
	exit 1
fi
FILTER_MILTER_HOST=$(echo "$FILTER_MILTER_ADDRESS" | cut -d: -f1)
FILTER_MILTER_PORT=$(echo "$FILTER_MILTER_ADDRESS" | cut -d: -f2)
if ! nc -z "$FILTER_MILTER_HOST" "$FILTER_MILTER_PORT"; then
	echo "Healthcheck failed: cannot connect to $FILTER_MILTER_ADDRESS"
	exit 1
fi

echo "Healthcheck passed"

exit 0
