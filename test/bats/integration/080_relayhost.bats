#!/usr/bin/env bats

setup() {
	load '_helper'

	mapfile -t parts < <(split_by_colon "${MTA_SMTP_SUBMISSION_ADDRESS}")
	SMTP_SUBMISSION_HOST="${parts[0]}"
	SMTP_SUBMISSION_PORT="${parts[1]}"
}

@test "check mailpit api for messages" {
	if [ "${RELAYHOST}" = "false" ]; then
		echo '# Relayhost is disabled, skipping test' >&3
		skip
	fi

	run curl "http://mailpit:8025/api/v1/messages"
	[ "$status" -eq 0 ]
}

@test "send mail to mta with smtp authentification, external recipient" {
	if [ "${RELAYHOST}" = "false" ]; then
		echo '# Relayhost is disabled, skipping test' >&3
		skip
	fi

	run swaks -s "${SMTP_SUBMISSION_HOST}" --port "${SMTP_SUBMISSION_PORT}" --to nobody@ressourcenkonflikt.de --from admin@example.com -a -au admin@example.com -ap changeme -tls --body "$BATS_TEST_DESCRIPTION"
	[ "$status" -eq 0 ]
}

@test "check mailpit api for outgoing message" {
	if [ "${RELAYHOST}" = "false" ]; then
		echo '# Relayhost is disabled, skipping test' >&3
		skip
	fi

	sleep 5 # Give mailpit some time

	RESULT=$(curl -s "http://mailpit:8025/api/v1/messages" | jq -cr ".messages[0].Snippet" | tr -d '[:space:]')

	# send mail to mta with smtp authentification, external recipient
	[ "$RESULT" = "sendmailtomtawithsmtpauthentification,externalrecipient" ]
}
