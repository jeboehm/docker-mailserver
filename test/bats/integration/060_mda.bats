#!/usr/bin/env bats

setup() {
	load '_helper'

	# Messages in the INBOX of admin@example.com as stored on disk. The counts
	# reported over IMAP and POP3 have to match it exactly.
	INBOX_COUNT="$(find "$(maildir admin@example.com)/new" "$(maildir admin@example.com)/cur" -type f | wc -l | tr -d ' ')"
}

@test "count mails in inbox via imap" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run mail_count imap "${MDA_IMAP_ADDRESS}" admin@example.com changeme
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via imaps" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run mail_count imaps "${MDA_IMAPS_ADDRESS}" admin@example.com changeme
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via pop3" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run mail_count pop3 "${MDA_POP3_ADDRESS}" admin@example.com changeme
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "count mails in inbox via pop3s" {
	[ "${INBOX_COUNT}" -gt 0 ]

	run mail_count pop3s "${MDA_POP3S_ADDRESS}" admin@example.com changeme
	assert_success
	assert_output "${INBOX_COUNT}"
}

@test "mail moved to the Junk folder is learned as spam by rspamd" {
	# Moving mail into Junk runs Dovecot's learn-spam sieve script, which
	# feeds the message to the rspamd controller (rspamc.sh). The test moves
	# the mail it sends itself, the newest message in the INBOX, so that the
	# outcome does not depend on what earlier runs left behind.
	learned_before="$(service_log_count filter 'learned message as spam')"

	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success

	run mail_count imap "${MDA_IMAP_ADDRESS}" admin@example.com changeme
	assert_success
	[ "${output}" -gt 0 ]

	run mail_move imap "${MDA_IMAP_ADDRESS}" admin@example.com changeme INBOX "${output}" Junk
	assert_success

	run wait_for_log filter 'rspamd_controller_learn_fin_task.*learned message as spam' "$((learned_before + 1))"
	assert_success
}

@test "imap login to send only mailbox is not possible" {
	run mail_count imap "${MDA_IMAP_ADDRESS}" sendonly@example.com test1234
	assert_failure
}

@test "pop3 login to send only mailbox is not possible" {
	run mail_count pop3 "${MDA_POP3_ADDRESS}" sendonly@example.com test1234
	assert_failure
}

@test "pop3 login to quota mailbox is possible" {
	run mail_count pop3 "${MDA_POP3_ADDRESS}" quota@example.com test1234
	assert_success
}

@test "imap login to quota mailbox is possible" {
	run mail_count imap "${MDA_IMAP_ADDRESS}" quota@example.com test1234
	assert_success
}

@test "pop3 login to disabled mailbox is not possible" {
	run mail_count pop3 "${MDA_POP3_ADDRESS}" disabled@example.com test1234
	assert_failure
}

@test "imap login to disabled mailbox is not possible" {
	run mail_count imap "${MDA_IMAP_ADDRESS}" disabled@example.com test1234
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
