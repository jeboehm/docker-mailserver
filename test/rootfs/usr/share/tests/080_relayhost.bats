#!/usr/bin/env bats

@test "check mailhog api for messages" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    run curl "http://mailhog:8025/api/v2/messages"
    [ "$status" -eq 0 ]
}

@test "send mail to mta with smtp authentification, external recipient" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    run swaks -s mta --port 587 --to nobody@ressourcenkonflikt.de --from admin@example.com -a -au admin@example.com -ap changeme -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "check mailhog api for outgoing message" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    sleep 5 # Give mailhog some time

    RESULT=$(curl -s "http://mailhog:8025/api/v2/messages" | jq -cr .items[0].Content.Body | tr -d '[:space:]')

    # send mail to mta with smtp authentification, external recipient
    [ "$RESULT" = "sendmailtomtawithsmtpauthentification,externalrecipient" ]
}
