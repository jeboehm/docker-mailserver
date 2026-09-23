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

# Run curl against an SMTP service with the transcript (--verbose) on stdout,
# so that tests can assert on the server's replies. Postfix accepts at most 20
# connections per minute from one client on each of its services
# (smtpd_client_connection_rate_limit), which test runs started back to back
# exceed. A 421 greeting for that reason is a temporary failure: wait for the
# rate window to pass and try again.
# Usage: smtp_curl <curl options...>
smtp_curl() {
	local attempt=0
	local output
	local status

	while :; do
		output="$(curl --no-progress-meter --show-error --verbose --insecure "$@" 2>&1)"
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

# Print an RFC 5322 message with CRLF line endings (Postfix rejects bare
# newlines). A "Subject: ..." header line replaces the default subject, every
# other header line is added as it is. With an attachment the message becomes
# multipart/mixed with the file base64 encoded, which grows it by about a third.
# Usage: mail_message <from> <to> <body> <attachment file or empty> [header line...]
mail_message() {
	local from="$1"
	local to="$2"
	local body="$3"
	local attach="$4"
	shift 4

	local subject="test mail"
	local header
	local headers=()
	for header in "$@"; do
		case "${header}" in
		Subject:*) subject="${header#Subject:}" && subject="${subject# }" ;;
		*) headers+=("${header}") ;;
		esac
	done

	printf 'Date: %s\r\n' "$(date -R)"
	printf 'From: %s\r\n' "${from}"
	printf 'To: %s\r\n' "${to}"
	printf 'Subject: %s\r\n' "${subject}"
	printf 'Message-ID: <%s%s.%s@%s>\r\n' "${RANDOM}" "${RANDOM}" "$(date +%s)" "$(hostname)"
	for header in "${headers[@]}"; do
		printf '%s\r\n' "${header}"
	done

	if [ -z "${attach}" ]; then
		printf '\r\n%s\r\n' "${body}"
		return
	fi

	local boundary="boundary${RANDOM}${RANDOM}${RANDOM}"
	local name
	name="$(basename "${attach}")"
	printf 'MIME-Version: 1.0\r\n'
	printf 'Content-Type: multipart/mixed; boundary="%s"\r\n' "${boundary}"
	printf '\r\n--%s\r\n' "${boundary}"
	printf 'Content-Type: text/plain; charset=us-ascii\r\n'
	printf '\r\n%s\r\n' "${body}"
	printf '\r\n--%s\r\n' "${boundary}"
	printf 'Content-Type: application/octet-stream; name="%s"\r\n' "${name}"
	printf 'Content-Transfer-Encoding: base64\r\n'
	printf 'Content-Disposition: attachment; filename="%s"\r\n\r\n' "${name}"
	base64 "${attach}" | sed 's/$/\r/'
	printf '\r\n--%s--\r\n' "${boundary}"
}

# Send a mail with curl. --tls requires STARTTLS; credentials are used whenever
# the server offers AUTH (curl skips authentication silently when it does not,
# check smtp_ehlo for that). --data sends the file as the complete message,
# otherwise mail_message builds one. The output is the SMTP transcript. Exit
# codes that tests rely on:
#   55  MAIL, RCPT or DATA rejected ("RCPT failed: 554" in the output)
#    8  message rejected after DATA, or a non-2xx greeting
#   67  authentication rejected
#   64  STARTTLS refused
# Usage: send_mail --server <host:port> --to <address> [--from <address>] [--tls]
#        [--auth-user <user> --auth-password <password>] [--header <line>]...
#        [--body <text>] [--attach <file>] [--data <file>]
send_mail() {
	local server=""
	local to=""
	local from
	from="$(id -un)@$(hostname)"
	local tls=0
	local user=""
	local password=""
	local body=""
	local attach=""
	local data=""
	local headers=()

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--server) server="$2" && shift 2 ;;
		--to) to="$2" && shift 2 ;;
		--from) from="$2" && shift 2 ;;
		--tls) tls=1 && shift ;;
		--auth-user) user="$2" && shift 2 ;;
		--auth-password) password="$2" && shift 2 ;;
		--header) headers+=("$2") && shift 2 ;;
		--body) body="$2" && shift 2 ;;
		--attach) attach="$2" && shift 2 ;;
		--data) data="$2" && shift 2 ;;
		*)
			echo "send_mail: unknown option $1" >&2
			return 1
			;;
		esac
	done
	if [ -z "${server}" ] || [ -z "${to}" ]; then
		echo "send_mail: --server and --to are required" >&2
		return 1
	fi

	local message
	message="$(mktemp -p "${BATS_TEST_TMPDIR:-/tmp}" mail.XXXXXX)"
	if [ -n "${data}" ]; then
		sed 's/\r$//; s/$/\r/' "${data}" >"${message}"
	else
		mail_message "${from}" "${to}" "${body}" "${attach}" "${headers[@]}" >"${message}"
	fi

	local options=(--url "smtp://${server}" --mail-from "${from}" --mail-rcpt "${to}" --upload-file "${message}")
	[ "${tls}" -eq 1 ] && options+=(--ssl-reqd)
	[ -n "${user}" ] && options+=(--user "${user}:${password}")

	smtp_curl "${options[@]}"
}

# Print the transcript of an SMTP session that only sends EHLO (and STARTTLS
# with --tls) followed by NOOP: shows which capabilities a service advertises,
# e.g. whether "250-AUTH" is offered.
# Usage: smtp_ehlo <host:port> [--tls]
smtp_ehlo() {
	local address="$1"
	shift

	local options=(--request NOOP --url "smtp://${address}")
	[ "${1:-}" = "--tls" ] && options+=(--ssl-reqd)

	smtp_curl "${options[@]}"
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

# Run curl against an IMAP or POP3 service. imap and pop3 require STARTTLS,
# imaps and pop3s use implicit TLS.
# Usage: mail_curl <imap|imaps|pop3|pop3s> <host:port> <user> <password> <path> [curl options...]
mail_curl() {
	local scheme="$1"
	local address="$2"
	local user="$3"
	local password="$4"
	local path="$5"
	shift 5

	local options=(--no-progress-meter --show-error --insecure --user "${user}:${password}")
	case "${scheme}" in
	imap | pop3) options+=(--ssl-reqd) ;;
	esac

	curl "${options[@]}" "$@" "${scheme}://${address}/${path}"
}

# Count the messages in the INBOX of a mailbox as an IMAP or POP3 client sees
# them. Fails when the login is rejected (curl exits with 67).
# Usage: mail_count <imap|imaps|pop3|pop3s> <host:port> <user> <password>
mail_count() {
	local scheme="$1"
	local output

	case "${scheme}" in
	imap | imaps)
		output="$(mail_curl "$@" "" --request "STATUS INBOX (MESSAGES)")" || return $?
		sed -nE 's/.*MESSAGES ([0-9]+).*/\1/p' <<<"${output}"
		;;
	pop3 | pop3s)
		# The default POP3 command is LIST: one line per message.
		output="$(mail_curl "$@" "")" || return $?
		grep -c . <<<"${output}" || true
		;;
	*)
		echo "mail_count: unknown scheme ${scheme}" >&2
		return 1
		;;
	esac
}

# Move one message, addressed by its IMAP sequence number (1 = first), into
# another folder. A rejected MOVE makes curl exit with 21.
# Usage: mail_move <imap|imaps> <host:port> <user> <password> <from folder> <sequence> <to folder>
mail_move() {
	local from="$5"
	local sequence="$6"
	local to="$7"

	mail_curl "$1" "$2" "$3" "$4" "${from}" --request "MOVE ${sequence} ${to}"
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
