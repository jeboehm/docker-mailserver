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

# Run a command inside a service container (Docker Compose) or pod (Kubernetes).
# Usage: exec_in_service <service> <command> [args...]
exec_in_service() {
	local service="$1"
	shift

	if [ "${IS_KUBERNETES}" -eq "1" ]; then
		case "${service}" in
		filter | mta | mda)
			kubectl exec "statefulset/${service}" -- "$@"
			;;
		*)
			kubectl exec "deploy/${service}" -- "$@"
			;;
		esac
	else
		docker exec "${COMPOSE_PROJECT_NAME:-docker-mailserver}-${service}-1" "$@"
	fi
}

# Wait until a message containing the needle shows up in a Maildir and print
# the path of the first match. Only new/ and cur/ are searched so that Dovecot
# index files are ignored.
# Usage: wait_for_mail <needle> <maildir> [timeout_seconds]
wait_for_mail() {
	local needle="$1"
	local maildir="$2"
	local timeout="${3:-60}"
	local waited=0
	local match

	while [ "${waited}" -lt "${timeout}" ]; do
		match="$(grep -rlF -- "${needle}" "${maildir}/new" "${maildir}/cur" 2>/dev/null | head -n 1)"

		if [ -n "${match}" ]; then
			echo "${match}"
			return 0
		fi

		sleep 1
		waited=$((waited + 1))
	done

	echo "Timed out after ${timeout}s waiting for '${needle}' in ${maildir}" >&2
	return 1
}

# Print the unfolded value of a header (case-insensitive) from a mail file.
# Usage: mail_header <file> <header-name>
mail_header() {
	local file="$1"
	local name

	name="$(printf '%s:' "$2" | tr '[:upper:]' '[:lower:]')"

	tr -d '\r' <"${file}" | awk -v name="${name}" '
		/^$/ { exit }
		/^[ \t]/ { if (found) { sub(/^[ \t]+/, " "); printf "%s", $0 }; next }
		{
			if (found) { exit }
			if (index(tolower($0), name) == 1) {
				found = 1
				value = substr($0, length(name) + 1)
				sub(/^[ \t]+/, "", value)
				printf "%s", value
			}
		}
		END { if (found) { print "" } }
	'
}
