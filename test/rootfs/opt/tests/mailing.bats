#!/usr/bin/env bats
@test "send mail to local address" {
    swaks --to admin@example.com
    [ "$?" -eq 0 ]
}

@test "send mail to local address with extension" {
    swaks --to admin-test@example.com
    [ "$?" -eq 0 ]
}

@test "send mail with smtp authentification" {
    swaks --to admin@example.com --from admin@example.com -a -au admin@example.com -ap changeme -s example.com -tls
    [ "$?" -eq 0 ]
}

@test "maildir exists" {
    sleep 3
    ls -lh /var/vmail/example.com/admin/Maildir/new/
    [ "$?" -eq 0 ]
}

@test "maildir contains files" {
    files="$(ls -1 /var/vmail/example.com/admin/Maildir/new/ | wc -l)"
    [ "$files" -gt 2 ]
}

@test "send junk mail to local address" {
    swaks --to admin@example.com --data sample-spam.txt
    [ "$?" -eq 0 ]
}

@test "check junk mail in junk folder (sieve rule is working)" {
    sleep 3
    files="$(ls -1 /var/vmail/example.com/admin/Maildir/.Junk/new/ | wc -l)"
    [ "$files" -gt 0 ]
}
