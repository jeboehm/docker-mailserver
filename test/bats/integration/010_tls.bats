#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "certificates were created" {
	[ -f /media/tls/tls.crt ]
}

@test "mda and mta present the same certificate" {
	mda_fingerprint="$(tls_fingerprint "${MDA_IMAPS_ADDRESS}")"
	mta_fingerprint="$(tls_fingerprint "${MTA_SMTP_ADDRESS}" -starttls smtp)"

	[ -n "${mda_fingerprint}" ]
	[ "${mda_fingerprint}" = "${mta_fingerprint}" ]
}

@test "connection to imaps" {
	run tls_connect "${MDA_IMAPS_ADDRESS}" "a1 LOGOUT"
	assert_success
}

@test "connection to pop3s" {
	run tls_connect "${MDA_POP3S_ADDRESS}" "QUIT"
	assert_success
}

@test "connection to pop3 with starttls" {
	run tls_connect "${MDA_POP3_ADDRESS}" "QUIT" -starttls pop3
	assert_success
}

@test "connection to imap with starttls" {
	run tls_connect "${MDA_IMAP_ADDRESS}" "a1 LOGOUT" -starttls imap
	assert_success
}

@test "connection to smtp with starttls" {
	run tls_connect "${MTA_SMTP_ADDRESS}" "QUIT" -starttls smtp
	assert_success
}

@test "connection to submission with starttls" {
	run tls_connect "${MTA_SMTP_SUBMISSION_ADDRESS}" "QUIT" -starttls smtp
	assert_success
}

@test "submission rejects TLS 1.1" {
	run tls_connect "${MTA_SMTP_SUBMISSION_ADDRESS}" "QUIT" -starttls smtp -tls1_1
	assert_failure
}

@test "submission accepts TLS 1.2" {
	run tls_connect "${MTA_SMTP_SUBMISSION_ADDRESS}" "QUIT" -starttls smtp -tls1_2
	assert_success
}
