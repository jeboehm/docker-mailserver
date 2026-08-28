#!/bin/sh
#
# Database fixtures for the integration tests, created through the
# mailserver-admin console inside the web image. `make fixtures` feeds this
# script to the running Compose container; the load-fixtures init container in
# test/k8s/test-job.yaml mounts it from the test-fixtures ConfigMap.
#
# The script is rerunnable: it exits early when example.com already exists.
#
# FIXTURES_MDA_IMAP_ADDRESS is the host:port under which the fetchmail
# container reaches Dovecot's IMAP port. Compose links mda as mda.local into
# the fetchmail container (docker-compose.test.yml); Kubernetes overrides it
# with the address of the mda Service in test-job.yaml.
set -e

: "${FIXTURES_MDA_IMAP_ADDRESS:=mda.local:31143}"

# stdin is closed for every command so that none of them can consume the rest
# of this script when it is piped into `sh`.
console() {
	/opt/admin/bin/console "$@" </dev/null
}

console system:check --wait

# mailserver-admin has no domain:list. domain:add fails with
# "name: This value is already used." when the domain exists; any other
# failure (database down, invalid name) is an error.
if ! output="$(console domain:add example.com 2>&1)"; then
	case "${output}" in
	*"already used"*)
		echo "Fixtures already loaded (example.com exists), nothing to do."
		exit 0
		;;
	*)
		printf '%s\n' "${output}" >&2
		exit 1
		;;
	esac
fi
printf '%s\n' "${output}"

console domain:add example.org
console user:add --admin --password=changeme --enable admin example.com
console user:add --password=test1234 --enable --sendonly sendonly example.com
console user:add --password=test1234 --enable --quota=1 quota example.com
console user:add --password=test1234 disabled example.com
console user:add --password=test1234 --sendonly disabledsendonly example.com
console user:add --password=test1234 --enable fetchmailsource example.org
console user:add --password=test1234 --enable fetchmailreceiver example.org
console alias:add foo@example.com admin@example.com
console alias:add foo@example.org admin@example.com
console alias:add --catchall @example.com admin@example.com
console dkim:setup example.com --enable --selector dkim
console fetchmail:account:add --force fetchmailreceiver@example.org \
	"${FIXTURES_MDA_IMAP_ADDRESS%%:*}" imap "${FIXTURES_MDA_IMAP_ADDRESS##*:}" \
	fetchmailsource@example.org test1234
