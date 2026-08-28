#!/usr/bin/env bats

setup() {
	load '_helper'

	DKIM_RECORD_NAME="dkim._domainkey.example.com"
	ADMIN_MAILDIR="$(maildir admin@example.com)"
}

teardown_file() {
	# The rotation tests leave a stale record in unbound. Publish the current
	# key again so that signing keeps working for whatever runs after this file.
	load '_helper'
	publish_dkim_record dkim.example.com >/dev/null 2>&1 || true
}

# Print the base64 encoded public key (the "p=" value of the DNS record)
# derived from the private key rspamd loads from redis.
# Usage: dkim_public_key <selector>.<domain>
dkim_public_key() {
	redis_cli --raw hget dkim_keys "$1" | openssl pkey -pubout 2>/dev/null | sed '/^-----/d' | tr -d '\n'
}

# Split a TXT value into quoted character-strings of at most 255 bytes.
# Usage: dns_txt_chunks <value>
dns_txt_chunks() {
	local value="$1"
	local out=""

	while [ -n "${value}" ]; do
		out="${out}\"${value:0:255}\" "
		value="${value:255}"
	done

	printf '%s' "${out% }"
}

# Publish the DKIM record for the key currently stored in redis into the
# running unbound. Replaces a previously published record.
# Usage: publish_dkim_record <selector>.<domain>
publish_dkim_record() {
	local selector="${1%%.*}"
	local domain="${1#*.}"
	local name="${selector}._domainkey.${domain}"
	local pubkey

	pubkey="$(dkim_public_key "$1")"
	[ -n "${pubkey}" ] || return 1

	# Same layout as the record printed by `console dkim:setup`. The TTL of one
	# second matters: rspamd caches verified public keys for the TTL of the
	# record, and after the key rotation below a cached key would fail the
	# verification of the next run.
	exec_in_service unbound unbound-control local_data_remove "${name}." >/dev/null
	exec_in_service unbound unbound-control local_data "${name}. 1 IN TXT $(dns_txt_chunks "v=DKIM1; h=sha256; t=s; p=${pubkey}")"
}

# Print the joined TXT value that unbound returns for a name.
# Usage: dns_txt_record <name>
dns_txt_record() {
	dns_query +short "$1" TXT | sed 's/" "//g; s/^"//; s/"$//'
}

# Send a mail through the submission service with the needle as subject and
# body. The needle is used to find the stored message afterwards.
# Usage: send_submission_mail <needle>
send_submission_mail() {
	send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --header "Subject: $1" --body "$1"
}

@test "check DKIM key for example.com exists" {
	run redis_cli hget dkim_keys dkim.example.com
	assert_success
	assert_output --partial "BEGIN PRIVATE KEY"
}

@test "publish DKIM TXT record for example.com to unbound" {
	# rspamd only signs when the public key of the domain resolves through
	# unbound (dkim_signing check_pubkey). Nobody publishes example.com in the
	# test environment, so the record is injected into the running unbound.
	pubkey="$(dkim_public_key dkim.example.com)"
	[ -n "${pubkey}" ]

	run publish_dkim_record dkim.example.com
	assert_success
	assert_output "ok"

	run dns_txt_record "${DKIM_RECORD_NAME}"
	assert_success
	assert_output --partial "p=${pubkey}"
}

@test "mail via submission service is signed with DKIM" {
	run send_submission_mail "$(mail_needle)"
	assert_success

	mail_file="$(wait_for_mail "$(mail_needle)" "${ADMIN_MAILDIR}")"
	[ -n "${mail_file}" ]

	run mail_header "${mail_file}" DKIM-Signature
	assert_success
	assert_output --partial "a=rsa-sha256"
	assert_output --regexp '(^|[; ])d=example\.com;'
	assert_output --regexp '(^|[; ])s=dkim;'
}

@test "DKIM signature is valid for the published record" {
	run send_submission_mail "$(mail_needle)"
	assert_success

	mail_file="$(wait_for_mail "$(mail_needle)" "${ADMIN_MAILDIR}")"
	[ -n "${mail_file}" ]

	# rspamd does not verify DKIM for local or authenticated senders
	# (check_local / check_authed default to false), so pretend the message
	# arrives from an external MX. The verifier resolves the public key
	# through unbound, where the record was published above.
	run curl -fsS -X POST "http://${FILTER_WEB_ADDRESS}/checkv2" -H "Password: ${CONTROLLER_PASSWORD}" -H "IP: 198.51.100.10" -H "Hostname: mx.example.net" --data-binary "@${mail_file}"
	assert_success

	run jq -e '.symbols.R_DKIM_ALLOW' <<<"${output}"
	assert_success
	assert_output --partial "example.com:s=dkim"
}

@test "rotate DKIM key for example.com without updating DNS" {
	old_pubkey="$(dkim_public_key dkim.example.com)"
	[ -n "${old_pubkey}" ]

	# The confirmation question of --regenerate defaults to yes. --enable is
	# needed because dkim:setup sets the enabled flag from the option each time.
	run exec_in_service web /opt/admin/bin/console dkim:setup example.com --regenerate --enable --no-interaction
	assert_success
	assert_output --partial "v=DKIM1;"

	new_pubkey="$(dkim_public_key dkim.example.com)"
	[ -n "${new_pubkey}" ]
	[ "${new_pubkey}" != "${old_pubkey}" ]

	# The published record still carries the previous public key.
	run dns_txt_record "${DKIM_RECORD_NAME}"
	assert_output --partial "p=${old_pubkey}"
}

@test "mail sent after the DKIM key rotation is not signed" {
	# The DNS record does not match the new private key, so rspamd refuses to
	# sign (allow_pubkey_mismatch = false) and the mail leaves unsigned.
	run send_submission_mail "$(mail_needle)"
	assert_success

	mail_file="$(wait_for_mail "$(mail_needle)" "${ADMIN_MAILDIR}")"
	[ -n "${mail_file}" ]

	run mail_header "${mail_file}" DKIM-Signature
	assert_success
	assert_output ""
}
