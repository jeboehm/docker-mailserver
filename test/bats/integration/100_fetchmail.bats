#!/usr/bin/env bats

setup() {
	load '_helper'

	if [ "${MDA_UPSTREAM_PROXY}" = "true" ]; then
		skip "MDA upstream proxy is enabled, fetchmail cannot connect to the mda"
	fi
}

@test "fetchmail collects mail from the fetchmailsource account into the fetchmailreceiver account" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to fetchmailsource@example.org --body "$(mail_needle)"
	assert_success

	# fetchmail polls the source account every FETCHMAIL_INTERVAL seconds.
	run wait_for_mail "$(mail_needle)" "$(maildir fetchmailreceiver@example.org)" "$((FETCHMAIL_INTERVAL + 60))"
	assert_success
}
