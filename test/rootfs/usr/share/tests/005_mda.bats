#!/usr/bin/env bats

@test "count mails in inbox via imap" {
    run imap-tester test:count mda 143 admin@example.com changeme INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via imaps" {
    run imap-tester test:count mda 993 admin@example.com changeme INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3" {
    run imap-tester test:count mda 110 admin@example.com changeme INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3s" {
    run imap-tester test:count mda 995 admin@example.com changeme INBOX
    [ "$output" -gt 3 ]
}
}

@test "mails are owned by vmail" {
    run find /var/vmail/example.com/ -not -user 5000
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
