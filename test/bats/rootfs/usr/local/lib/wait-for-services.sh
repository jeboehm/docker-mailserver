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

# Wait for Filter Web
if [ -z "$FILTER_WEB_ADDRESS" ]; then
	echo "Error: FILTER_WEB_ADDRESS not set"
	exit 1
fi
FILTER_WEB_HOST=$(echo "$FILTER_WEB_ADDRESS" | cut -d: -f1)
FILTER_WEB_PORT=$(echo "$FILTER_WEB_ADDRESS" | cut -d: -f2)
wait_for_service "$FILTER_WEB_HOST" "$FILTER_WEB_PORT" "Filter Web"

# Wait for MDA IMAP
if [ -z "$MDA_IMAP_ADDRESS" ]; then
	echo "Error: MDA_IMAP_ADDRESS not set"
	exit 1
fi
MDA_IMAP_HOST=$(echo "$MDA_IMAP_ADDRESS" | cut -d: -f1)
MDA_IMAP_PORT=$(echo "$MDA_IMAP_ADDRESS" | cut -d: -f2)
wait_for_service "$MDA_IMAP_HOST" "$MDA_IMAP_PORT" "MDA IMAP"

# Wait for MTA SMTP Submission
if [ -z "$MTA_SMTP_SUBMISSION_ADDRESS" ]; then
	echo "Error: MTA_SMTP_SUBMISSION_ADDRESS not set"
	exit 1
fi
MTA_SMTP_HOST=$(echo "$MTA_SMTP_SUBMISSION_ADDRESS" | cut -d: -f1)
MTA_SMTP_PORT=$(echo "$MTA_SMTP_SUBMISSION_ADDRESS" | cut -d: -f2)
wait_for_service "$MTA_SMTP_HOST" "$MTA_SMTP_PORT" "MTA SMTP Submission"

# Wait for Web HTTP
if [ -z "$WEB_HTTP_ADDRESS" ]; then
	echo "Error: WEB_HTTP_ADDRESS not set"
	exit 1
fi
WEB_HTTP_HOST=$(echo "$WEB_HTTP_ADDRESS" | cut -d: -f1)
WEB_HTTP_PORT=$(echo "$WEB_HTTP_ADDRESS" | cut -d: -f2)
wait_for_service "$WEB_HTTP_HOST" "$WEB_HTTP_PORT" "Web HTTP"
