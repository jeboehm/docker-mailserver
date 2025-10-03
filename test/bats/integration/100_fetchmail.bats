#!/usr/bin/env bats

@test "wait ${FETCHMAIL_INTERVAL} seconds to give fetchmail time to run" {
	if [ "${MDA_UPSTREAM_PROXY}" = "true" ]; then
		skip "MDA upstream proxy is enabled, skipping fetchmail test"
	fi

	run sleep "${FETCHMAIL_INTERVAL}"
}

@test "fetchmail collected the mail from the fetchmailsource account and put it into fetchmailreceiver account" {
	if [ "${MDA_UPSTREAM_PROXY}" = "true" ]; then
		skip "MDA upstream proxy is enabled, skipping fetchmail test"
	fi

	run grep -r "send mail to mta to fetchmail source account address" /srv/vmail/example.org/fetchmailreceiver/Maildir/
	[ "$status" -eq 0 ]
}
