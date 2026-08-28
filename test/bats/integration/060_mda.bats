#!/usr/bin/env bats

setup() {
	load '_helper'

	# Messages in the INBOX of admin@example.com as stored on disk. The counts
	# reported over IMAP and POP3 have to match it exactly.
	INBOX_COUNT="$(find "$(maildir admin@example.com)/new" "$(maildir admin@example.com)/cur" -type f | wc -l | tr -d ' ')"
}

@test "count mails in inbox via imap" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run imap_tester test:count "${MDA_IMAP_ADDRESS}" admin@example.com changeme imap tls INBOX
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via imaps" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run imap_tester test:count "${MDA_IMAPS_ADDRESS}" admin@example.com changeme imap ssl INBOX
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via pop3" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run imap_tester test:count "${MDA_POP3_ADDRESS}" admin@example.com changeme pop3 tls INBOX
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via pop3s" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run imap_tester test:count "${MDA_POP3S_ADDRESS}" admin@example.com changeme pop3 ssl INBOX
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "mail moved to the Junk folder is learned as spam by rspamd" {
	# Moving mail into Junk runs Dovecot's learn-spam sieve script, which
	# feeds the message to the rspamd controller (rspamc.sh).
	learned_before="$(service_log_count filter 'learned message as spam')"

	run imap_tester test:move "${MDA_IMAP_ADDRESS}" admin@example.com changeme imap tls INBOX 0 Junk
	assert_success

	run wait_for_log filter 'rspamd_controller_learn_fin_task.*learned message as spam' "$((learned_before + 1))"
	assert_success
}

@test "imap login to send only mailbox is not possible" {
	run imap_tester test:count "${MDA_IMAP_ADDRESS}" sendonly@example.com test1234 imap tls INBOX
	assert_failure
}

@test "pop3 login to send only mailbox is not possible" {
	run imap_tester test:count "${MDA_POP3_ADDRESS}" sendonly@example.com test1234 pop3 tls INBOX
	assert_failure
}

@test "pop3 login to quota mailbox is possible" {
	run imap_tester test:count "${MDA_POP3_ADDRESS}" quota@example.com test1234 pop3 tls INBOX
	assert_success
}

@test "imap login to quota mailbox is possible" {
	run imap_tester test:count "${MDA_IMAP_ADDRESS}" quota@example.com test1234 imap tls INBOX
	assert_success
}

@test "pop3 login to disabled mailbox is not possible" {
	run imap_tester test:count "${MDA_POP3_ADDRESS}" disabled@example.com test1234 pop3 tls INBOX
	assert_failure
}

@test "imap login to disabled mailbox is not possible" {
	run imap_tester test:count "${MDA_IMAP_ADDRESS}" disabled@example.com test1234 imap tls INBOX
	assert_failure
}

@test "mails are owned by vmail" {
	run find /srv/vmail/example.com/ -not -user 1000
	assert_success
	assert_output ""
}

@test "fulltext search index exists" {
	run ls "$(maildir admin@example.com)/fts-flatcurve/"*
	assert_success
}
