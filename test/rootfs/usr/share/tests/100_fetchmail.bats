#!/usr/bin/env bats

@test "wait ${FETCHMAIL_INTERVAL} seconds to give fetchmail time to run" {
	run sleep "${FETCHMAIL_INTERVAL}"
}

@test "fetchmail collected the mail from the fetchmailsource account and put it into fetchmailreceiver account" {
	run grep -r "send mail to mta to fetchmail source account address" /var/vmail/example.org/fetchmailreceiver/Maildir/
	[ "$status" -eq 0 ]
}
