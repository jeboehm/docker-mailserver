#!/usr/bin/env bats

@test "certificates were created" {
    [ -f /media/tls/mailserver.crt ]
}

@test "connection to imaps" {
    true | openssl s_client -showcerts -connect mda:993
    [ "$?" -eq 0 ]
}

@test "connection to pop3s" {
    true | openssl s_client -showcerts -connect mda:995
    [ "$?" -eq 0 ]
}

@test "connection to pop3 with starttls" {
    true | openssl s_client -showcerts -connect mda:110 -starttls pop3
    [ "$?" -eq 0 ]
}

@test "connection to imap with starttls" {
    true | openssl s_client -showcerts -connect mda:143 -starttls imap
    [ "$?" -eq 0 ]
}

@test "connection to smtp with starttls" {
    true | openssl s_client -showcerts -connect mta:25 -starttls smtp
    [ "$?" -eq 0 ]
}
