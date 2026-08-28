#!/usr/bin/env bats

# Every test sends its own mail with a unique body (mail_needle) and, where a
# delivery is expected, waits for that body to show up in the Maildir. Mail is
# sent through send_mail, which copes with Postfix's per-client connection
# rate limit.

setup() {
	load '_helper'
}

# --- inbound mail on port 25 -------------------------------------------------

@test "mail to local account address is delivered" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "mail to local address with extension is delivered" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin-test@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "mail to unknown address is delivered to the catchall" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to notexisting@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "mail to unknown address without catchall is rejected" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to notexisting@example.org --body "$(mail_needle)"
	assert_failure 24
}

@test "mail to local alias is delivered" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to foo@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "mail to a mailbox in the second domain is delivered" {
	# Not fetchmailsource@example.org: fetchmail empties that mailbox within
	# seconds, which would race with the check below.
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to fetchmailreceiver@example.org --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir fetchmailreceiver@example.org)"
	assert_success
}

@test "junk mail is sorted into the Junk folder" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin@example.com --header "X-Is-Spam: Yes" --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com Junk)"
	assert_success
}

@test "gtube mail is rejected" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin@example.com --data /usr/share/fixtures/gtube.txt
	assert_failure 26
}

@test "mail to disabled user is delivered anyway" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to disabled@example.com --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir disabled@example.com)"
	assert_success
}

@test "mail to send only mailbox is rejected" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to sendonly@example.com --body "$(mail_needle)"
	assert_failure 24
}

@test "mail to disabled and send only mailbox is rejected anyway" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to disabledsendonly@example.com --body "$(mail_needle)"
	assert_failure 24
}

@test "smtp authentication on port 25 is refused" {
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to admin@example.com --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_failure
}

# --- quota -------------------------------------------------------------------
#
# quota@example.com has a quota of 1 MiB (fixtures). Dovecot sends a warning
# when a delivery crosses one of the thresholds in 90-quota.conf (95% is
# listed first and wins when both are crossed at once), and quota_storage_grace
# (10 MiB by default) lets a delivery overshoot the limit as long as the
# mailbox is still below it. Both tests therefore start from an empty mailbox.

@test "mail filling the quota to about 80% triggers the quota warning" {
	run mailbox_reset quota@example.com
	assert_success

	# 640 KiB of random data is about 890 KiB once base64 encoded: above the
	# 80% threshold, below the 95% one.
	dd if=/dev/urandom of="${BATS_TEST_TMPDIR}/attachment" bs=64K count=10
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to quota@example.com --body "$(mail_needle)" --attach "@${BATS_TEST_TMPDIR}/attachment"
	assert_success

	# Delivered into the mailbox by quota-warning.sh.
	run wait_for_mail "Subject: Quota warning - 80% reached" "$(maildir quota@example.com)"
	assert_success

	run quota_percentage quota@example.com
	assert_success
	[ "${output}" -ge 80 ]
	[ "${output}" -lt 95 ]
}

@test "mail exceeding the quota is bounced" {
	run mailbox_reset quota@example.com
	assert_success

	# Fill the mailbox beyond its limit first. This delivery is still accepted
	# because of the grace; everything after it has to be rejected.
	dd if=/dev/urandom of="${BATS_TEST_TMPDIR}/filler" bs=100K count=8
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to quota@example.com --body "$(mail_needle) filler" --attach "@${BATS_TEST_TMPDIR}/filler"
	assert_success

	run wait_for_mail "$(mail_needle) filler" "$(maildir quota@example.com)"
	assert_success

	dd if=/dev/urandom of="${BATS_TEST_TMPDIR}/attachment" bs=1M count=5
	run send_mail --server "${MTA_SMTP_ADDRESS}" --to quota@example.com --body "$(mail_needle) oversized" --attach "@${BATS_TEST_TMPDIR}/attachment"
	assert_success

	# Postfix accepts the mail and Dovecot rejects it on LMTP delivery. Follow
	# the queue id from the SMTP response to the bounce in the MTA log.
	queue_id="$(sed -nE 's/.*queued as ([0-9A-Za-z]+).*/\1/p' <<<"${output}")"
	[ -n "${queue_id}" ]

	run wait_for_log mta "${queue_id}: to=<quota@example.com>.*status=bounced.*Quota exceeded"
	assert_success

	run find_mail "$(mail_needle) oversized" "$(maildir quota@example.com)"
	assert_failure
}

# --- submission service ------------------------------------------------------

@test "authentication with disabled account is refused" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from disabled@example.com --auth --auth-user disabled@example.com --auth-password test1234 --tls --body "$(mail_needle)"
	assert_failure 28
}

@test "authentication with disabled send only account is refused" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from disabledsendonly@example.com --auth --auth-user disabledsendonly@example.com --auth-password test1234 --tls --body "$(mail_needle)"
	assert_failure 28
}

@test "authentication without tls is refused" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --body "$(mail_needle)"
	assert_failure 28
}

@test "unauthenticated mail is rejected" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from disabled@example.com --tls --body "$(mail_needle)"
	assert_failure 24
}

@test "authenticated mail is delivered" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "authenticated mail has the client session hidden in the Received header" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_success

	mail_file="$(wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)")"
	[ -n "${mail_file}" ]

	# With "smtpd_hide_client_session=yes" (master.cf, submission service) the
	# submission smtpd must NOT leak the client's SASL login, TLS session or the
	# authenticated ESMTP protocol into the Received: header it generates.
	run grep -E "Authenticated sender:|with ESMTPSA|\(using TLS" "${mail_file}"
	assert_failure
}

@test "authenticated mail with address extension in the sender is delivered" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from admin-extension@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "authenticated mail from send only account is delivered" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from sendonly@example.com --auth --auth-user sendonly@example.com --auth-password test1234 --tls --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "authenticated mail with an alias as sender is delivered" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from foo@example.org --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_success

	run wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"
	assert_success
}

@test "authenticated mail with an unknown sender is rejected" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to admin@example.com --from unknown@example.org --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_failure 24
}
