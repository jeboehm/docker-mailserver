#!/usr/bin/env bats

@test "count mails in inbox via imap" {
	run imap-tester test:count mda 31143 admin@example.com changeme imap tls INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via imaps" {
	run imap-tester test:count mda 31993 admin@example.com changeme imap ssl INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3" {
	run imap-tester test:count mda 31110 admin@example.com changeme pop3 tls INBOX
	[ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3s" {
	run imap-tester test:count mda 31995 admin@example.com changeme pop3 ssl INBOX
	[ "$output" -gt 3 ]
}

@test "move mail to Junk folder (will test rspamc communication later)" {
	run imap-tester test:move mda 31143 admin@example.com changeme imap tls INBOX 0 Junk
	[ "$status" -eq 0 ]
}

@test "imap login to send only mailbox is not possible" {
	run imap-tester test:count mda 31143 sendonly@example.com test1234 imap tls INBOX
	[ "$status" -ne 0 ]
}

@test "pop3 login to send only mailbox is not possible" {
	run imap-tester test:count mda 31110 sendonly@example.com test1234 pop3 tls INBOX
	[ "$status" -ne 0 ]
}

@test "pop3 login to quota mailbox is possible" {
	run imap-tester test:count mda 31110 quota@example.com test1234 pop3 tls INBOX
	[ "$status" -eq 0 ]
}

@test "imap login to quota mailbox is possible" {
	run imap-tester test:count mda 31143 quota@example.com test1234 imap tls INBOX
	[ "$status" -eq 0 ]
}

@test "pop3 login to disabled mailbox is not possible" {
	run imap-tester test:count mda 31110 disabled@example.com test1234 pop3 tls INBOX
	[ "$status" -ne 0 ]
}

@test "imap login to disabled mailbox is not possible" {
	run imap-tester test:count mda 31143 disabled@example.com test1234 imap tls INBOX
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
