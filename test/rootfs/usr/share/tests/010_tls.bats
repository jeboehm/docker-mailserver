#!/usr/bin/env bats

@test "certificates were created" {
	[ -f /media/tls/mailserver.crt ]
}

@test "connection to imaps" {
	run openssl s_client -showcerts -connect mda:993
	[ "$status" -eq 0 ]
}

@test "connection to pop3s" {
	run openssl s_client -showcerts -connect mda:995
	[ "$status" -eq 0 ]
}

@test "connection to pop3 with starttls" {
	run openssl s_client -showcerts -connect mda:110 -starttls pop3
	[ "$status" -eq 0 ]
}

@test "connection to imap with starttls" {
	run openssl s_client -showcerts -connect mda:143 -starttls imap
	[ "$status" -eq 0 ]
}

@test "connection to smtp with starttls" {
	run openssl s_client -showcerts -connect mta:25 -starttls smtp
	[ "$status" -eq 0 ]
}
