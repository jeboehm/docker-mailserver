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

@test "imap login to send only mailbox is not possible" {
    run imap-tester test:count mda 143 sendonly@example.com test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "pop3 login to send only mailbox is not possible" {
    run imap-tester test:count mda 110 sendonly@example.com test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "pop3 login to quota mailbox is possible" {
    run imap-tester test:count mda 110 quota@example.com test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "imap login to quota mailbox is possible" {
    run imap-tester test:count mda 143 quota@example.com test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "mails are owned by vmail" {
    run find /var/vmail/example.com/ -not -user 5000
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
