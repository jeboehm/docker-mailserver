#!/usr/bin/env bats

setup() {
	load '_helper'

	mapfile -t parts < <(split_by_colon "${MDA_IMAP_ADDRESS}")
	MDA_IMAP_HOST="${parts[0]}"
	MDA_IMAP_PORT="${parts[1]}"

	mapfile -t parts < <(split_by_colon "${MDA_IMAPS_ADDRESS}")
	MDA_IMAPS_HOST="${parts[0]}"
	MDA_IMAPS_PORT="${parts[1]}"

	mapfile -t parts < <(split_by_colon "${MDA_POP3_ADDRESS}")
	MDA_POP3_HOST="${parts[0]}"
	MDA_POP3_PORT="${parts[1]}"

	mapfile -t parts < <(split_by_colon "${MDA_POP3S_ADDRESS}")
	MDA_POP3S_HOST="${parts[0]}"
	MDA_POP3S_PORT="${parts[1]}"
}

@test "count mails in inbox via imap" {
	run imap-tester test:count "${MDA_IMAP_HOST}" "${MDA_IMAP_PORT}" admin@example.com changeme imap tls INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via imaps" {
	run imap-tester test:count "${MDA_IMAPS_HOST}" "${MDA_IMAPS_PORT}" admin@example.com changeme imap ssl INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3" {
	run imap-tester test:count "${MDA_POP3_HOST}" "${MDA_POP3_PORT}" admin@example.com changeme pop3 tls INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3s" {
	run imap-tester test:count "${MDA_POP3S_HOST}" "${MDA_POP3S_PORT}" admin@example.com changeme pop3 ssl INBOX
	[ "$output" -gt 3 ]
}

@test "move mail to Junk folder (will test rspamc communication later)" {
	run imap-tester test:move "${MDA_IMAP_HOST}" "${MDA_IMAP_PORT}" admin@example.com changeme imap tls INBOX 0 Junk
	[ "$status" -eq 0 ]
}

@test "imap login to send only mailbox is not possible" {
	run imap-tester test:count "${MDA_IMAP_HOST}" "${MDA_IMAP_PORT}" sendonly@example.com test1234 imap tls INBOX
	[ "$status" -ne 0 ]
}

@test "pop3 login to send only mailbox is not possible" {
	run imap-tester test:count "${MDA_POP3_HOST}" "${MDA_POP3_PORT}" sendonly@example.com test1234 pop3 tls INBOX
	[ "$status" -ne 0 ]
}

@test "pop3 login to quota mailbox is possible" {
	run imap-tester test:count "${MDA_POP3_HOST}" "${MDA_POP3_PORT}" quota@example.com test1234 pop3 tls INBOX
	[ "$status" -eq 0 ]
}

@test "imap login to quota mailbox is possible" {
	run imap-tester test:count "${MDA_IMAP_HOST}" "${MDA_IMAP_PORT}" quota@example.com test1234 imap tls INBOX
	[ "$status" -eq 0 ]
}

@test "pop3 login to disabled mailbox is not possible" {
	run imap-tester test:count "${MDA_POP3_HOST}" "${MDA_POP3_PORT}" disabled@example.com test1234 pop3 tls INBOX
	[ "$status" -ne 0 ]
}

@test "imap login to disabled mailbox is not possible" {
	run imap-tester test:count "${MDA_IMAP_HOST}" "${MDA_IMAP_PORT}" disabled@example.com test1234 imap tls INBOX
	[ "$status" -ne 0 ]
}

@test "mails are owned by vmail" {
	run find /srv/vmail/example.com/ -not -user 1000
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "fulltext search index exists" {
	run ls /srv/vmail/example.com/admin/Maildir/fts-flatcurve/*

	[ "$status" -eq 0 ]
}
