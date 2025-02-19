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

@test "move mail to Junk folder (will test rspamc communication later)" {
    run imap-tester test:move mda 143 admin@example.com changeme INBOX 0 Junk
    [ "$status" -eq 0 ]
}

@test "imap login to send only mailbox is not possible" {
    run imap-tester test:count mda 143 sendonly@example.com test1234 INBOX
    ! [ "$status" -eq 0 ]
}

@test "pop3 login to send only mailbox is not possible" {
    run imap-tester test:count mda 110 sendonly@example.com test1234 INBOX
    ! [ "$status" -eq 0 ]
}

@test "pop3 login to quota mailbox is possible" {
    run imap-tester test:count mda 110 quota@example.com test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "imap login to quota mailbox is possible" {
    run imap-tester test:count mda 143 quota@example.com test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "pop3 login to disabled mailbox is not possible" {
    run imap-tester test:count mda 110 disabled@example.com test1234 INBOX
    ! [ "$status" -eq 0 ]
}

@test "imap login to disabled mailbox is not possible" {
    run imap-tester test:count mda 143 disabled@example.com test1234 INBOX
    ! [ "$status" -eq 0 ]
}

@test "mails are owned by vmail" {
    run find /var/vmail/example.com/ -not -user 5000
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "fts-xapian index exists" {
    if [ ${ENABLE_FTS} = "false" ]; then
        skip
    fi

    run ls /var/vmail/example.com/admin/Maildir/xapian-indexes/*

    [ "$status" -eq 0 ]
}

@test "fts-xapian index does not exist" {
    if [ ${ENABLE_FTS} = "true" ]; then
        skip
    fi

    run ls /var/vmail/example.com/admin/Maildir/xapian-indexes/*

    [ "$status" -eq 1 ]
}
