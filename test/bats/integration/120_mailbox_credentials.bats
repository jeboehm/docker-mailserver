#!/usr/bin/env bats

# Runs last on purpose. Every refused login delays the next logins from this address
# (Dovecot's auth penalty), and under that penalty submission can answer with a
# temporary failure, which would break whatever test sends mail next.

setup() {
	load '_helper'
}

teardown() {
	mailbox_credentials_clear 2>/dev/null || true
}

@test "a mailbox credential for smtp submits mail and does not log in on imap" {
	skip_without_mailbox_credentials

	secret="$(mailbox_credential admin example.com false true)"

	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --tls --auth-user 'cred#admin@example.com' --auth-password "${secret}" --from admin@example.com --to admin@example.com
	assert_success

	run mail_count imap "${MDA_IMAP_ADDRESS}" 'cred#admin@example.com' "${secret}"
	assert_failure 67
}

@test "a mailbox credential logs in as its user on imap and nowhere else" {
	skip_without_mailbox_credentials

	secret="$(mailbox_credential admin example.com true false)"

	run mail_count imap "${MDA_IMAP_ADDRESS}" 'cred#admin@example.com' "${secret}"
	assert_success

	run mail_count pop3 "${MDA_POP3_ADDRESS}" 'cred#admin@example.com' "${secret}"
	assert_failure 67

	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --tls --auth-user 'cred#admin@example.com' --auth-password "${secret}" --from admin@example.com --to admin@example.com
	assert_failure 67
}

@test "an expired mailbox credential does not log in" {
	skip_without_mailbox_credentials

	secret="$(mailbox_credential admin example.com true false -1)"

	run mail_count imap "${MDA_IMAP_ADDRESS}" 'cred#admin@example.com' "${secret}"
	assert_failure 67
}

@test "a mailbox credential does not read the mailbox of a send-only user" {
	skip_without_mailbox_credentials

	secret="$(mailbox_credential sendonly example.com true false)"

	run mail_count imap "${MDA_IMAP_ADDRESS}" 'cred#sendonly@example.com' "${secret}"
	assert_failure 67
}

@test "the password of a user does not log in with the credential prefix" {
	run mail_count imap "${MDA_IMAP_ADDRESS}" 'cred#admin@example.com' changeme
	assert_failure
}
