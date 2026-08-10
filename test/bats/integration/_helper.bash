#!/usr/bin/env bash

# Run a query against whichever database engine is configured.
# Usage: db_query "select * from mail_users;"
db_query() {
	if [ "${DB_DRIVER}" = "pgsql" ]; then
		PGPASSWORD="${DB_PASSWORD}" psql --no-psqlrc --quiet --tuples-only \
			-h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
			-c "$1"
	else
		mariadb --skip-ssl-verify-server-cert --batch -u "${DB_USER}" \
			--password="${DB_PASSWORD}" -h "${DB_HOST}" -P "${DB_PORT}" \
			"${DB_NAME}" -e "$1"
	fi
}

skip_in_kubernetes() {
	if [ "${IS_KUBERNETES}" -eq "1" ]; then
		skip "Skipping test in Kubernetes"
	fi
}

skip_in_non_kubernetes() {
	if [ "${IS_KUBERNETES}" -ne "1" ]; then
		skip "Skipping test in non-Kubernetes"
	fi
}

# Split a string by colon (:) character and return both parts
# Usage: split_by_colon "hostname:8080"
# Returns: Two lines - first part on line 1, second part on line 2
# Examples:
#   result=$(split_by_colon "localhost:8080")
#   part1=$(echo "$result" | head -n1)  # Gets "localhost"
#   part2=$(echo "$result" | tail -n1)  # Gets "8080"
#
#   # Alternative using read:
#   read -r part1 part2 < <(split_by_colon "hostname:8080")
#
#   # Using array:
#   parts=($(split_by_colon "hostname:8080"))
#   part1="${parts[0]}"
#   part2="${parts[1]}"
split_by_colon() {
	local input="$1"
	local part1="${input%%:*}"
	local part2="${input#*:}"
	echo "$part1"
	echo "$part2"
}
