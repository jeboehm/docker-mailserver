#!/bin/sh
set -e

# Wait for service to be available using nc
wait_for_service() {
	(
		host="$1"
		port="$2"
		service_name="$3"
		timeout="${WAITSTART_TIMEOUT:-60s}"

		# Convert timeout to seconds (handle formats like "1m", "60s", "60")
		timeout_seconds=60
		if echo "$timeout" | grep -q "m$"; then
			timeout_seconds=$(echo "$timeout" | sed 's/m$//' | awk '{print $1 * 60}')
		elif echo "$timeout" | grep -q "s$"; then
			timeout_seconds=$(echo "$timeout" | sed 's/s$//')
		else
			timeout_seconds="$timeout"
		fi

		elapsed=0
		interval=1

		echo "Waiting for $service_name at $host:$port..."
		while [ "$elapsed" -lt "$timeout_seconds" ]; do
			if nc -z "$host" "$port" 2>/dev/null; then
				echo "$service_name is available"
				exit 0
			fi
			sleep "$interval"
			elapsed=$((elapsed + interval))
		done

		echo "Error: Timeout waiting for $service_name at $host:$port"
		exit 1
	)
}

# Wait for MySQL
if [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_PORT" ]; then
	echo "Error: MYSQL_HOST or MYSQL_PORT not set"
	exit 1
fi
wait_for_service "$MYSQL_HOST" "$MYSQL_PORT" "MySQL"

# Wait for MDA LMTP
if [ -z "$MDA_LMTP_ADDRESS" ]; then
	echo "Error: MDA_LMTP_ADDRESS not set"
	exit 1
fi
MDA_LMTP_HOST=$(echo "$MDA_LMTP_ADDRESS" | cut -d: -f1)
MDA_LMTP_PORT=$(echo "$MDA_LMTP_ADDRESS" | cut -d: -f2)
wait_for_service "$MDA_LMTP_HOST" "$MDA_LMTP_PORT" "MDA LMTP"

# Wait for Filter Milter
if [ -z "$FILTER_MILTER_ADDRESS" ]; then
	echo "Error: FILTER_MILTER_ADDRESS not set"
	exit 1
fi
FILTER_MILTER_HOST=$(echo "$FILTER_MILTER_ADDRESS" | cut -d: -f1)
FILTER_MILTER_PORT=$(echo "$FILTER_MILTER_ADDRESS" | cut -d: -f2)
wait_for_service "$FILTER_MILTER_HOST" "$FILTER_MILTER_PORT" "Filter Milter"
