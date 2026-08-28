#!/usr/bin/env bash
#
# Shared helpers for the integration tests. Load with `load '_helper'` in
# setup(); this also makes bats-support and bats-assert (assert_success,
# assert_output, ...) available.

bats_load_library 'bats-support'
bats_load_library 'bats-assert'

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------

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

# The relayhost (mailpit) is only configured in the relayhost matrix case.
skip_without_relayhost() {
	if [ "${RELAYHOST}" = "false" ]; then
		skip "RELAYHOST is disabled"
	fi
}

# ---------------------------------------------------------------------------
# Services
# ---------------------------------------------------------------------------

# Resolve the Docker Compose project the test runner belongs to into
# COMPOSE_PROJECT, from the labels of its own container (the hostname is the
# container id). COMPOSE_PROJECT_NAME wins when set, e.g. when the runner is
# started outside of Compose.
compose_project() {
	[ -n "${COMPOSE_PROJECT:-}" ] && return 0

	COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-$(docker inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' "$(hostname)")}"

	if [ -z "${COMPOSE_PROJECT}" ]; then
		echo "Cannot determine the Compose project of container $(hostname); set COMPOSE_PROJECT_NAME" >&2
		return 1
	fi
}

# Id of the running Docker Compose container of a service, usable with
# docker exec/logs.
# Usage: compose_container <service>
compose_container() {
	local id

	compose_project || return 1
	id="$(docker ps -q --filter "label=com.docker.compose.project=${COMPOSE_PROJECT}" --filter "label=com.docker.compose.service=$1" | head -n 1)"

	if [ -z "${id}" ]; then
		echo "No running container for service $1 in Compose project ${COMPOSE_PROJECT}" >&2
		return 1
	fi

	echo "${id}"
}

# Kubernetes workload of a service, usable with kubectl exec/logs.
kubernetes_workload() {
	case "$1" in
	filter | mta | mda)
		echo "statefulset/$1"
		;;
	*)
		echo "deploy/$1"
		;;
	esac
}

# Kubernetes container name of a service. The pods are named after the
# service, the containers after the software they run.
kubernetes_container() {
	case "$1" in
	filter)
		echo "rspamd"
		;;
	mta)
		echo "postfix"
		;;
	mda)
		echo "dovecot"
		;;
	fetchmail)
		echo "fetchmailmgr"
		;;
	*)
		echo "$1"
		;;
	esac
}

# Run a command inside a service container (Docker Compose) or pod (Kubernetes).
# Usage: exec_in_service <service> <command> [args...]
exec_in_service() {
	local service="$1"
	shift

	if [ "${IS_KUBERNETES}" -eq "1" ]; then
		kubectl exec "$(kubernetes_workload "${service}")" -c "$(kubernetes_container "${service}")" -- "$@"
	else
		docker exec "$(compose_container "${service}")" "$@"
	fi
}

# Print the logs of a service.
# Usage: service_logs <service>
service_logs() {
	if [ "${IS_KUBERNETES}" -eq "1" ]; then
		kubectl logs "$(kubernetes_workload "$1")" -c "$(kubernetes_container "$1")"
	else
		docker logs "$(compose_container "$1")" 2>&1
	fi
}

# Print the number of log lines of a service that match an extended regex.
# Usage: service_log_count <service> <pattern>
service_log_count() {
	service_logs "$1" | grep -cE -- "$2" || true
}

# Succeed when at least <count> (default 1) log lines of a service match.
# Usage: service_logs_contain <service> <pattern> [count]
service_logs_contain() {
	[ "$(service_log_count "$1" "$2")" -ge "${3:-1}" ]
}

# ---------------------------------------------------------------------------
# Waiting
# ---------------------------------------------------------------------------

# Retry a command once per second until it succeeds or the timeout expires.
# The output of the command is discarded.
# Usage: wait_for <timeout_seconds> <command> [args...]
wait_for() {
	local timeout="$1"
	local waited=0
	shift

	until "$@" >/dev/null 2>&1; do
		if [ "${waited}" -ge "${timeout}" ]; then
			echo "Timed out after ${timeout}s waiting for: $*" >&2
			return 1
		fi

		sleep 1
		waited=$((waited + 1))
	done
}

# Wait until at least <count> (default 1) log lines of a service match an
# extended regex.
# Usage: wait_for_log <service> <pattern> [count] [timeout_seconds]
wait_for_log() {
	wait_for "${4:-60}" service_logs_contain "$1" "$2" "${3:-1}"
}

# ---------------------------------------------------------------------------
# Mail
# ---------------------------------------------------------------------------

# Send a mail with swaks. Postfix accepts at most 20 connections per minute
# from one client on each of its services (smtpd_client_connection_rate_limit),
# which test runs started back to back exceed. A 421 greeting for that reason
# is a temporary failure: wait for the rate window to pass and try again.
# Usage: send_mail <swaks options...>
send_mail() {
	local attempt=0
	local output
	local status

	while :; do
		output="$(swaks "$@" 2>&1)"
		status=$?

		case "${output}" in
		*"421 4.7.0"*"too many connections"*)
			if [ "${attempt}" -lt 6 ]; then
				attempt=$((attempt + 1))
				echo "Postfix connection rate limit hit, retrying in 10s" >&2
				sleep 10
				continue
			fi
			;;
		esac

		printf '%s\n' "${output}"
		return "${status}"
	done
}

# Print a string that identifies a mail sent by the current test in the
# current bats run. Use it as body and search for it afterwards, so that
# mails left behind by earlier runs in the persistent Maildir do not match.
# Usage: mail_needle
mail_needle() {
	echo "${BATS_TEST_DESCRIPTION} [${BATS_RUN_TMPDIR##*/}]"
}

# Print the Maildir of a mailbox, or of a folder inside it, as mounted into
# the test runner.
# Usage: maildir <address> [folder]
maildir() {
	local address="$1"
	local folder="${2:-}"

	echo "/srv/vmail/${address#*@}/${address%%@*}/Maildir${folder:+/.${folder}}"
}

# Print the path of the first message in a Maildir that contains the needle.
# Only new/ and cur/ are searched so that Dovecot index files are ignored.
# Usage: find_mail <needle> <maildir>
find_mail() {
	local match

	match="$(grep -rlF -- "$1" "$2/new" "$2/cur" 2>/dev/null | head -n 1)"
	[ -n "${match}" ] && echo "${match}"
}

# Wait until a message containing the needle shows up in a Maildir and print
# its path.
# Usage: wait_for_mail <needle> <maildir> [timeout_seconds]
wait_for_mail() {
	wait_for "${3:-60}" find_mail "$1" "$2" && find_mail "$1" "$2"
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

# ---------------------------------------------------------------------------
# Mailboxes (Dovecot)
# ---------------------------------------------------------------------------

# Expunge every message of a mailbox in all of its folders and recalculate
# its quota usage. /srv/vmail is mounted read-only into the runner, so this
# goes through doveadm in the mda container. doveadm insists on a mailbox
# term in the search query; '*' matches every folder.
# Usage: mailbox_reset <address>
mailbox_reset() {
	exec_in_service mda doveadm expunge -u "$1" mailbox '*' all &&
		exec_in_service mda doveadm quota recalc -u "$1"
}

# Print the storage usage of a mailbox in percent of its quota.
# Usage: quota_percentage <address>
quota_percentage() {
	exec_in_service mda doveadm -f tab quota get -u "$1" | awk -F '\t' '$2 == "STORAGE" { print $5 }'
}

# ---------------------------------------------------------------------------
# Clients
# ---------------------------------------------------------------------------

# Run a query against whichever database engine is configured. Prints rows
# only, without column names or alignment.
# Usage: db_query "select * from mail_users;"
db_query() {
	if [ "${DB_DRIVER}" = "pgsql" ]; then
		PGPASSWORD="${DB_PASSWORD}" psql --no-psqlrc --quiet --tuples-only --no-align \
			-h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
			-c "$1"
	else
		mariadb --skip-ssl-verify-server-cert --batch --skip-column-names -u "${DB_USER}" \
			--password="${DB_PASSWORD}" -h "${DB_HOST}" -P "${DB_PORT}" \
			"${DB_NAME}" -e "$1"
	fi
}

# Run a redis command.
# Usage: redis_cli <command> [args...]
redis_cli() {
	REDISCLI_AUTH="${REDIS_PASSWORD}" redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" "$@"
}

# Query unbound with dig.
# Usage: dns_query [dig options...] <name> [type]
dns_query() {
	dig "@${UNBOUND_DNS_ADDRESS%%:*}" -p "${UNBOUND_DNS_ADDRESS##*:}" "$@"
}

# Run imap-tester against a host:port address.
# Usage: imap_tester <command> <address> <user> <password> <imap|pop3> <tls|ssl> [args...]
imap_tester() {
	local command="$1"
	local address="$2"
	shift 2

	imap-tester "${command}" "${address%%:*}" "${address##*:}" "$@"
}

# Open a TLS connection with openssl s_client, send one line and wait for the
# server to close the connection.
# Usage: tls_connect <address> <line> [s_client options...]
tls_connect() {
	local address="$1"
	local line="$2"
	shift 2

	printf '%s\r\n' "${line}" | openssl s_client -quiet -brief -connect "${address}" "$@"
}

# Print the fingerprint of the certificate a service presents.
# Usage: tls_fingerprint <address> [s_client options...]
tls_fingerprint() {
	local address="$1"
	shift

	echo | openssl s_client -showcerts -connect "${address}" "$@" 2>/dev/null | openssl x509 -fingerprint -noout
}
