#!/usr/bin/env bats

setup() {
	load '_helper'
	skip_without_relayhost

	MAILPIT_API="http://mailpit:8025/api/v1"
}

# Succeed when mailpit holds a message whose body contains the needle.
# Usage: mailpit_has_message <needle>
mailpit_has_message() {
	curl -fsS "${MAILPIT_API}/messages" | jq -e --arg needle "$1" '.messages[] | select((.Snippet // "") | contains($needle))' >/dev/null
}

@test "mailpit api is reachable" {
	run curl -fsS "${MAILPIT_API}/messages"
	assert_success
}

@test "authenticated mail to an external recipient is relayed to mailpit" {
	run send_mail --server "${MTA_SMTP_SUBMISSION_ADDRESS}" --to nobody@example.net --from admin@example.com --auth --auth-user admin@example.com --auth-password changeme --tls --body "$(mail_needle)"
	assert_success

	run wait_for 60 mailpit_has_message "$(mail_needle)"
	assert_success
}
